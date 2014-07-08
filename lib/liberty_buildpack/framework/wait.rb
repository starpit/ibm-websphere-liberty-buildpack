require 'liberty_buildpack/framework'
require 'liberty_buildpack/repository/configured_item'
require 'liberty_buildpack/util/format_duration'
require 'liberty_buildpack/util'
require 'liberty_buildpack/util/java_main_utils'

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

    def detect
       true
    end

    # i don't think we have anything to do here, yet. here is where we'd download the necessary files
    #
    # @return [void]
    def compile
    end

    # here is i think where we need to spawn the data collector script?
    #
    # @return [void]
    def release
      resources = File.expand_path(RESOURCES, File.dirname(__FILE__))
      script = File.join resources, "waitDataCollector.sh"
      FileUtils.chmod "u=rwx", script

      working_directory = File.join LibertyBuildpack::Diagnostics.get_diagnostic_directory(@app_dir), "wait"
      FileUtils.mkdir_p working_directory

      puts "WAIT initializing with working_directory=#{working_directory}"

      command = "#{script} --processName java --sleep 5 --iters 10"
      @pid = spawn script, :chdir=>working_directory

      puts "WAIT initialized with working_directory=#{working_directory} and running as pid=#{@pid}"
    end

    private
       RESOURCES = '../../../resources/wait'.freeze

  end
end