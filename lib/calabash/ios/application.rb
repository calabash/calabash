module Calabash
  module IOS
    class Application < Calabash::Application

      def initialize(application_path, options = {})
        super(application_path, options)
      end

    end
  end
end
