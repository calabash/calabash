module Calabash
  module CLI
    module Console
      def parse_console_arguments!
        application = @arguments.shift

        if application.nil?
          Logger.info("No application specified. Using default application specified by env variable CALABASH_APP")
          application = Environment.default_application_path
          Logger.debug("New application: '#{application}'")

          fail("No application given and env variable CALABASH_APP is not set.", :console) if application.nil?
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
              # TODO: Extract ID from ipa
              raise 'FOR NOW WE CANT DO THIS'
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
        path = Environment.variable('CALABASH_IRBRC')
        path ||= File.expand_path('.irbrc') if File.exist?('.irbrc')

        if @platform == :android
          path ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'android', 'lib', '.irbrc'))

          unless Environment.variable('APP_PATH')
            Environment.set_variable!('APP_PATH', application_path)
          end

          unless Environment.variable('TEST_APP_PATH')
            test_server = Android::Build::TestServer.new(application_path)

            raise 'Cannot locate test-server' unless test_server.exists?

            Environment.set_variable!('TEST_APP_PATH', test_server.path)
          end

          unless Environment.variable('MAIN_ACTIVITY')
            main_activity = Android::Build::Application.new(application_path).main_activity
            Environment.set_variable!('MAIN_ACTIVITY', main_activity)
          end
        elsif @platform == :ios
          path ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'ios', 'lib', '.irbrc'))

          Environment.set_variable!('APP_BUNDLE_PATH', application_path)
        else
          raise "Invalid platform '#{@platform}'"
        end

        Environment.set_variable!('IRBRC', path)

        environment = {'CALABASH_DEBUG' => @options[:verbose] ? '1' : '0'}

        Logger.info 'Running irb...'

        exec(environment, 'irb')
      end
    end
  end
end