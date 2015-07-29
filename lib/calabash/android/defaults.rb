module Calabash
  module Android
    def self.setup_defaults!
      # Setup the default application
      Calabash.default_application = Application.default_from_environment

      # Setup the default device
      identifier = Device.default_serial
      server = Server.default

      Calabash.default_device = Device.new(identifier, server)
      end
  end
end
