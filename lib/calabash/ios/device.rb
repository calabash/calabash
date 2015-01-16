module Calabash
  module IOS
    class Device < ::Calabash::Device
      # TODO: Implement this method, remember to add unit tests
      def self.list_devices
        raise 'ni'
      end

      # @todo this is a partial solution
      def calabash_start_app(application, options={})
        launch_opts =
            {
                :app => application.path,
                :device_target => self.identifier,
                :uia_strategy => :preferences,
            }


        RunLoop.run(launch_opts)
        ensure_test_server_ready
        extract_device_info!(fetch_device_info)
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
