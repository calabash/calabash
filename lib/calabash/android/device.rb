module Calabash
  module Android
    class Device < Calabash::Android::Operations::Device
      def self.list_devices
        connected_devices
      end

      def adb(command)
        full_command = "#{Environment.adb_path} -s #{identifier} #{command}"
        @logger.log("Executing: #{full_command}")
        `#{full_command}`
      end

      def installed_apps
        adb('shell pm list packages').lines.map do |line|
          {id: line.sub('package:', '').chomp}
        end
      end

      def clear_app(params)

      end

      def test_server_responding?
        begin
          @http_client.get(HTTP::Request.new('ping')).body == 'pong'
        rescue HTTP::Error => _
          false
        end
      end
    end
  end
end
