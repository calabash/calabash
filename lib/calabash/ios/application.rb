module Calabash
  module IOS
    class Application < Calabash::Application
      def self.default_from_environment
        application_path = Environment::APP_PATH

        if application_path.nil?
          raise 'No application path is set'
        end

        Application.new(application_path)
      end

      def initialize(application_path, options = {})
        super(application_path, options)
      end

      def simulator_bundle?
        File.extname(path) == '.app'
      end

      def device_binary?
        File.extname(path) == '.ipa'
      end
    end
  end
end
