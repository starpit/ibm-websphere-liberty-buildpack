require 'liberty_buildpack/framework'
require 'liberty_buildpack/diagnostics/common'

require 'fileutils'

module LibertyBuildpack::Framework

  # Encapsulates the detect, compile, and release functionality for enabling Icap Monitor Agent in
  # applications.
  class IBMWaitMonitor

    # Creates an instance, passing in an arbitrary collection of options.
    #
    # @param [Hash] context the context that is provided to the instance
    # @option context [Array<String>] :java_opts an array that Java options can be added to
    # @option context [Hash] :configuration the properties provided by the user
    def initialize(context = {})
      @java_opts = context[:java_opts]
      @configuration = context[:configuration]
      @app_dir = context[:app_dir]
      @vcap_services = context[:vcap_services]
      @vcap_application = context[:vcap_application]
    end

    # @return [String] returns the service name?? this has to be a string, i think
    def detect
      ""
    end

    # i don't think we have anything to do here, yet. here is where we'd download the necessary files
    #
    # @return [void]
    def compile
      resources = File.expand_path(RESOURCES, File.dirname(__FILE__))
      @agent_jar = File.join resources, "stack-collector-agent.jar"
    end

    # here is i think where we need to spawn the data collector script?
    #
    # @return [void]
    def release
      javaagent = "-javaagent:#{@agent_jar}"
      @java_opts << javaagent
      puts "@@@@@@@@@@@@@@@@@ #{@java_opts}"
    end

    def release2
      begin

      resources = File.expand_path(RESOURCES, File.dirname(__FILE__))
      script = File.join resources, "waitDataCollector.sh"
      FileUtils.chmod "u=rwx", script

      working_directory = File.join LibertyBuildpack::Diagnostics.get_diagnostic_directory(@app_dir), "wait"
      FileUtils.mkdir_p working_directory

      command = "#{script} --processName java --sleep 5 --iters 10"
      @pid = spawn script, :chdir=>working_directory

      rescue Exception => e
         oops e
      end

      true
    end

    private
       RESOURCES = '../../../resources/wait'.freeze

       def oops(e)
          puts e
       end
  end
end