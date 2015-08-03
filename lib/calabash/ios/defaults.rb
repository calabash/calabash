module Calabash
  module IOS
    module Defaults
      def setup_defaults!
        setup_default_application!
        setup_default_device!
      end

      def setup_default_device!
        if Calabash.default_application.nil?
          raise 'Cannot setup default device for iOS, as no default Application has been set'
        end

        # Setup the default device
        identifier =
            Device.default_identifier_for_application(Calabash.default_application)

        server = Server.default

        Calabash.default_device = Device.new(identifier, server)
      end

      def setup_default_application!
        # Setup the default application
        Calabash.default_application = Application.default_from_environment
      end
    end
  end
end
