module Calabash
  module IOS
    class Server < ::Calabash::Server
      def self.default
        endpoint = Environment::DEVICE_ENDPOINT
        Server.new(endpoint)
      end
    end
  end
end
