module Calabash
  module CLI
    module Run
      def parse_run_arguments!
        first_argument = @arguments.first # Do not remove the entry from the arguments yet - it might be a cucumber arg

        if first_argument.nil? || first_argument.start_with?('-')
          # If the argument begins with a dash, we assume the user meant
          # to specify a cucumber argument, not an application
          Logger.info("No application specified. Using default application specified by env variable CAL_APP")
          application = Environment::APP_PATH
          Logger.debug("New application: '#{application}'")

          fail("No application given and env variable CAL_APP is not set.", :run) if application.nil?
        else
          # If the argument does not begin with a dash, we assume the user meant
          # to specify an application, not a cucumber argument
          application = @arguments.shift
        end

        if File.exists?(application)
          extension = File.extname(application)
          application_path = File.expand_path(application)

          case extension
            when '.apk'
              set_platform!(:android)

              # Create the test server if it does not exist
              test_server = Android::Build::TestServer.new(application_path)

              unless test_server.exists?
                Logger.info('Test server does not exist. Creating test server.')
                Calabash::Android::Build::Builder.new(application_path).build
              end

              run(application_path, @arguments)
            when '.ipa'
              set_platform!(:ios)
              # TODO: Extract ID from ipa
              raise 'FOR NOW WE CANT DO THIS'
            when '.app'
              set_platform!(:ios)
              run(application_path, @arguments)
            else
              fail('Application must be either an .apk, .ipa or .app', :run)
          end
        else
          fail("File '#{application}' does not exist", :run)
        end
      end

      def run(application_path, cucumber_arguments)
        cucumber_environment = {}
        cucumber_environment['CAL_DEBUG'] = Environment::DEBUG ? '1' : '0'

        if @options[:verbose]
          cucumber_environment['CAL_DEBUG'] = '1'
        end

        if @platform == :android
          cucumber_environment['CAL_APP'] = Environment::APP_PATH || application_path

          if Environment::TEST_SERVER_PATH
            cucumber_environment['CAL_TEST_SERVER'] = Environment::TEST_SERVER_PATH
          else
            test_server = Android::Build::TestServer.new(application_path)

            raise 'Cannot locate test-server' unless test_server.exists?

            cucumber_environment['CAL_TEST_SERVER'] = test_server.path
          end
        elsif @platform == :ios
          Environment.set_variable!('APP_BUNDLE_PATH', application_path)
        else
          raise "Invalid platform '#{@platform}'"
        end

        arguments = ['-S', 'cucumber', '-p', @platform.to_s, *cucumber_arguments]

        Logger.debug("Starting Ruby with arguments: #{arguments.join(', ')} and environment #{cucumber_environment.to_s}")

        exec(cucumber_environment, RbConfig.ruby, *arguments)
      end
    end
  end
end
