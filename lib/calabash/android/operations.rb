module Calabash
  module Android
    module Operations
      def _start_test_server(options={})
        test_options = options.dup

        test_options[:main_activity] ||= Environment.variable('MAIN_ACTIVITY')

        application_path = test_options[:application_path] || Environment.variable('APP_PATH')
        test_server_path = test_options[:test_server_path] || Environment.variable('TEST_APP_PATH')

        test_options.delete(:application_path)
        test_options.delete(:test_server_path)

        application = Build::Application.new(application_path)
        test_server = Build::Application.new(test_server_path)

        Calabash::Device.default.start_test_server(application, test_server, test_options)
      end
    end
  end
end
