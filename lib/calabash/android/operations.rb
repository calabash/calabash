module Calabash
  module Android
    module Operations
      def _calabash_start_app(options={})
        test_options = options.dup

        test_options[:main_activity] ||= Environment.variable('MAIN_ACTIVITY')

        application_path = test_options[:application_path] || Environment.variable('APP_PATH')
        test_server_path = test_options[:test_server_path] || Environment.variable('TEST_APP_PATH')

        test_options.delete(:application_path)
        test_options.delete(:test_server_path)

        application = Application.new(application_path, test_server_path)

        Calabash::Device.default.calabash_start_app(application, test_options)
      end

      def _calabash_stop_app(options={})
        Calabash::Device.default.calabash_stop_app(options)
      end
    end
  end
end
