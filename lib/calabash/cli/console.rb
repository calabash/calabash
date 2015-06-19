module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Console
      def parse_console_arguments!
        application = @arguments.shift

        if application.nil?
          Logger.info("No application specified. Using default application specified by env variable CAL_APP")
          application = Environment::APP_PATH
          Logger.debug("New application: '#{application}'")

          fail("No application given and env variable CAL_APP is not set.", :console) if application.nil?
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

              enter_console(application_path)
            when '.ipa'
              set_platform!(:ios)
              enter_console(application_path)
            when '.app'
              set_platform!(:ios)
              enter_console(application_path)
            else
              fail('Application must be either an .apk, .ipa or .app', :console)
          end
        else
          fail("File '#{application}' does not exist", :console)
        end
      end

      def enter_console(application_path)
        irbrc_path = Environment::IRBRC

        console_environment = {}
        console_environment['CAL_DEBUG'] = Environment::DEBUG ? '1' : '0'

        if @options[:verbose]
          console_environment['CAL_DEBUG'] = '1'
        end

        if @platform == :android
          irbrc_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'android', 'lib', '.irbrc'))

          console_environment['CAL_APP'] = application_path

          if Environment::TEST_SERVER_PATH
            console_environment['CAL_TEST_SERVER'] = Environment::TEST_SERVER_PATH
          else
            test_server = Android::Build::TestServer.new(application_path)

            raise 'Cannot locate test-server' unless test_server.exists?

            console_environment['CAL_TEST_SERVER'] = test_server.path
          end
        elsif @platform == :ios
          irbrc_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'ios', 'lib', '.irbrc'))

          console_environment['CAL_APP'] = application_path
        else
          raise "Invalid platform '#{@platform}'"
        end

        console_environment['IRBRC'] = irbrc_path

        Logger.info 'Running irb...'
        Logger.debug "From file: '#{irbrc_path}'"
        Logger.debug "With ENV: '#{console_environment}'"

        exec(console_environment, RbConfig.ruby, '-S', 'irb')
      end
    end
  end
end
