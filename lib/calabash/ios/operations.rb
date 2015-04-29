module Calabash
  module IOS
    module Operations
      def _calabash_start_app(options={})
        test_options = options.dup

        app_path = Environment::APP_PATH
        # @todo: fix
        application_identifier = Environment.variable('BUNDLE_ID')

        application_path = test_options.fetch(:application_path, app_path)
        application_identifier = test_options.fetch(:application_identifier, application_identifier)

        test_options.delete(:application_path)
        test_options.delete(:application_identifier)

        app = Calabash::Application.new(application_path, {:identifier => application_identifier})
        Calabash::Device.default.calabash_start_app(app, test_options)
      end

      def _calabash_stop_app(options={})
        Calabash::Device.default.calabash_stop_app(options)
      end
    end
  end
end