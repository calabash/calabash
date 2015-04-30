module Calabash
  module Android
    module Operations
      def _reinstall(opt={})
        uninstall(Application.default)
        install(Application.default)
      end

      def _calabash_start_app(options={})
        test_options = options.dup

        application_path = test_options[:application_path] || Environment::APP_PATH
        test_server_path = test_options[:test_server_path] || Environment::TEST_SERVER_PATH

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
