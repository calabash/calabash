module Calabash
  module IOS
    class Server < ::Calabash::Server
      def self.default
        endpoint = Environment::DEVICE_ENDPOINT
        Server.new(endpoint)
      end

      def localhost?
        endpoint.hostname == 'localhost' || endpoint.hostname == '127.0.0.1'
      end
    end
  end
end
