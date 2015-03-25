module Calabash
  module IOS
    class Device < ::Calabash::Device

      attr_reader :run_loop

      # TODO: Implement this method, remember to add unit tests
      def self.list_devices
        raise 'ni'
      end

      def calabash_start_app(application, options={})
        default_opts =
            {
                :app => application.path,
                :device_target => self.identifier,
                :uia_strategy => :preferences,
            }

        launch_opts = default_opts.merge(options)
        @run_loop = RunLoop.run(launch_opts)
        ensure_test_server_ready
        device_info = fetch_device_info
        extract_device_info!(device_info)
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
