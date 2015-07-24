module Calabash
  module Defaults
    # Get the default device. The device represents a physical device,
    # an emulator, or a simulator. Calabash will communicate with this
    # device by default.
    #
    # @return [Calabash::Device] The default device
    def default_device
      Device.default
    end

    # Set the default device.
    #
    # @see #Calabash::Defaults#default_device
    def default_device=(device)
      Device.default = device
    end

    # Get the default application. The application represents an .ipa, .app, or
    # .apk. For Android, the application can represent a test-server along side
    # the application under test. Calabash will use this application by
    # default, for example when calling install_app.
    #
    # @return [Calabash::Application] The default application
    def default_application
      Application.default
    end

    # Set the default application.
    #
    # @see #Calabash::Defaults.default_application
    def default_application=(application)
      Application.default = application
    end
  end
end
