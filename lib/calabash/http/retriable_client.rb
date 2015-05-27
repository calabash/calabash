require 'httpclient'

module Calabash
  module HTTP
    class RetriableClient
      attr_reader :client

       RETRY_ON =
        [
          # The connection, request, or response timed out
          #HTTPClient::TimeoutError,
          # The proxy could not connect to the server (Android)
          #  or the server is not running (iOS)
          HTTPClient::KeepAliveDisconnected,
           # No proxy has been set up (Android)
          Errno::ECONNREFUSED,
          # The server sent a partial response
          #Errno::ECONNRESET,
          # Client sent TCP reset (RST) before server has accepted the
          #  connection requested by client.
          Errno::ECONNABORTED,
          # The foreign function call call timed out
          #Errno::ETIMEDOUT
        ]

      def initialize(server, options = {})
        @client = options[:client] || ::HTTPClient.new
        @server = server
        @retries = options.fetch(:retries, 5)
        @timeout = options.fetch(:timeout, 5)
        @interval = options.fetch(:interval, 0.5)
        @logger = options[:logger] || Calabash::Logger.new
      end

      def get(request, options={})
        request(request, :get, options)
      end

      def post(request, options={})
        request(request, :post, options)
      end

      private

      def request(request, request_method, options={})
        retries = options.fetch(:retries, @retries)
        timeout = options.fetch(:timeout, @timeout)
        interval = options.fetch(:interval, @interval)

        @logger.log "Getting: #{@server.endpoint + request.route}"

        start_time = Time.now
        last_error = nil

        client = @client.dup
        client.receive_timeout = timeout

        retries.times do
          time_diff = start_time + timeout - Time.now

          if time_diff <= 0
            raise HTTP::Error, 'Timeout exceeded'
          end

          client.receive_timeout = [time_diff, client.receive_timeout].min

          begin
            return client.send(request_method, @server.endpoint + request.route, request.params)
          rescue *RETRY_ON => e
            @logger.log "Http error: #{e}"
            last_error = e
            sleep interval
          end
        end

        # We should raise helpful messages
        if last_error.is_a?(HTTPClient::KeepAliveDisconnected)
          raise HTTP::Error, "#{last_error}: It is likely your application has crashed"
        end

        raise HTTP::Error, last_error
      end
    end
  end
end
