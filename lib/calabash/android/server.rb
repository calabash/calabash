module Calabash
  module Android
    # A representation of the Calabash Android test server.
    class Server < ::Calabash::Server
      def self.default
        Server.new(URI.parse('http://127.0.0.1:33765'))
      end
    end
  end
end
