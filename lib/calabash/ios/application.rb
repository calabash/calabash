module Calabash
  module IOS
    class Application < Calabash::Application
      def self.default_from_environment
        application_path = Environment::APP_PATH

        Application.new(application_path)
      end

      def initialize(application_path, options = {})
        super(application_path, options)
      end
    end
  end
end
