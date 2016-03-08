module Calabash
  module Android
    # A representation of the Calabash Android test server.
    class Server < ::Calabash::Server
      # The default Android test server.
      def self.default
        endpoint = Environment::DEVICE_ENDPOINT
        Server.new(endpoint, 7102)
      end
    end
  end
end
