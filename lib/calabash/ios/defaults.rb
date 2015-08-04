module Calabash
  module IOS
    module Defaults
      # Sets up the default application based on the
      # environment, and the default device based on the default application
      # and the environment.
      #
      # @see Calabash::IOS::Defaults#setup_default_application!
      # @see Calabash::IOS::Defaults#setup_default_device!
      # @see Calabash::Environment
      def setup_defaults!
        setup_default_application!
        setup_default_device!
      end

      # Sets up the default device based on the default application and the
      # environment.
      #
      # @raise [RuntimeError] Raises an error if the default application has
      #  not been set.
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

      # Sets up the default application based on the environment.
      def setup_default_application!
        # Setup the default application
        Calabash.default_application = Application.default_from_environment
      end
    end
  end
end
