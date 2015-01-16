module Calabash
  module IOS
    class Device < ::Calabash::Device
      # TODO: Implement this method, remember to add unit tests
      def self.list_devices
        raise 'ni'
      end

      def test_server_responding?
        begin
          http_client.get(HTTP::Request.new('version')).status.to_i == 200
        rescue HTTP::Error => _
          false
        end
      end
    end
  end
end
