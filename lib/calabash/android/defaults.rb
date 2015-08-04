module Calabash
  module Android
    module Defaults
      # Sets up the default device and the default application based on the
      # environment.
      #
      # @see Calabash::Android::Defaults#setup_default_application!
      # @see Calabash::Android::Defaults#setup_default_device!
      # @see Calabash::Environment
      def setup_defaults!
        setup_default_application!
        setup_default_device!
      end

      # Sets up the default application based on the environment.
      def setup_default_application!
        # Setup the default application
        Calabash.default_application = Application.default_from_environment
      end

      # Sets up the default device based on the environment.
      def setup_default_device!
        # Setup the default device
        identifier = Device.default_serial
        server = Server.default

        Calabash.default_device = Device.new(identifier, server)
      end
    end
  end
end
