module Calabash
  module IOS
    class Device < ::Calabash::Device

      attr_reader :run_loop

      # TODO: Implement this method, remember to add unit tests
      def self.list_devices
        raise 'ni'
      end

      def test_server_responding?
        begin
          http_client.get(Calabash::HTTP::Request.new('version')).status.to_i == 200
        rescue Calabash::HTTP::Error => _
          false
        end
      end

      def _screenshot(path)
        request = request_factory('screenshot', {:path => path})
        begin
         screenshot = http_client.get(request)
         File.open(path, 'wb') { |file| file.write screenshot }
        rescue Calabash::HTTP::Error => _
          raise "Could not send 'screenshot' to the app: #{e}"
        end
        path
      end

      private

      def _start_app(application, options={})
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

      def _stop_app
        return true unless test_server_responding?

        parameters = default_stop_app_parameters

        begin
          http_client.get(request_factory('exit', parameters))
        rescue Calabash::HTTP::Error => e
          raise "Could send 'exit' to the app: #{e}"
        end
      end

      def default_stop_app_parameters
        {
              :post_resign_active_delay => 0.4,
              :post_will_terminate_delay => 0.4,
              :exit_code => 0
        }
      end

      def request_factory(route, parameters={})
        Calabash::HTTP::Request.new(route, parameters)
      end
    end
  end
end
