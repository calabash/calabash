module Calabash
  module Android
    module Defaults
      def self.setup_defaults!
        setup_default_application!
        setup_default_device!
      end

      def self.setup_default_application!
        # Setup the default application
        Calabash.default_application = Application.default_from_environment
      end

      def self.setup_default_device!
        # Setup the default device
        identifier = Device.default_serial
        server = Server.default

        Calabash.default_device = Device.new(identifier, server)
      end
    end
  end
end
