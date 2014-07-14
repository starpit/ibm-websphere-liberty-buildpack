require 'liberty_buildpack/framework'
require 'liberty_buildpack/diagnostics/common'

#require 'fileutils'

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
      begin
         print "Beginning stack-collector-agent compile\n"

         resources = File.expand_path(RESOURCES, File.dirname(__FILE__))
         jars = File.join resources, "*.jar" #jar_name
         home_dir = File.join @app_dir, STACK_COLLECTOR_HOME
         print "jars=#{jars} home_dir=#{home_dir} java_opts=#{@java_opts}\n"

         system "rm -rf #{home_dir}"
         system "mkdir -p #{home_dir}"
         system "cp #{jars} #{home_dir}"

       rescue Exception => e
         oops e
       end
    end

    # here is i think where we need to spawn the data collector
    #
    # @return [void]
    def release
      begin
        begin
          main_class = LibertyBuildpack::Util::JavaMainUtils.main_class(@app_dir, @configuration)
        rescue
          main_class = nil
        end

        javaagent = main_class ? "-javaagent:#{File.join STACK_COLLECTOR_HOME, jar_name}" : "-javaagent:../../../../#{File.join STACK_COLLECTOR_HOME, jar_name}"
        @java_opts << javaagent

        @java_opts << "-Xbootclasspath/a:../../../../#{File.join STACK_COLLECTOR_HOME, prereq_jar}"

       rescue Exception => e
         oops e
       end
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
       STACK_COLLECTOR_HOME = '.Stack-Collector'.freeze

       RESOURCES = '../../../resources/wait'.freeze

       def jar_name
          "stack-collector-agent.jar"
       end

       def prereq_jar
          "wink-1.2.1-incubating.jar"
       end

       def oops(e)
          fail "Error in stack-collector-agent #{e}"
       end
  end
end