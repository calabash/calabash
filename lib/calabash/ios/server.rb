module Calabash
  module IOS
    class Server < ::Calabash::Server
      def self.default
        Server.new(URI.parse('http://127.0.0.1:32765'))
      end
    end
  end
end
