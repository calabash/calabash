require 'httpclient'

module Calabash
  module HTTP

    # An HTTP client that retries its connection on errors and can time out.
    # @!visibility private
    class RetriableClient
      attr_reader :client

      # @!visibility private
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

      # @!visibility private
      HEADER =
            {
                  'Content-Type' => 'application/json;charset=utf-8'
            }

      # @!visibility private
      attr_accessor :port_forward

      # Creates a new retriable client.
      #
      # This initializer takes multiple options.  If the option is not
      # documented, it should be considered _private_. You use undocumented
      # options at your own risk.
      #
      # @param [Calabash::Server] server The server to make the HTTP request
      #  on.
      # @param [Hash] options Control the retry, timeout, and interval.
      # @option options [Number] :retries (5) How often to retry.
      # @option options [Number] :timeout (5) How long to wait for a response
      #  before timing out.
      # @option options [Number] :interval (0.5) How long to sleep between
      #  retries.
      def initialize(server, options = {})
        @client = options[:client] || ::HTTPClient.new
        @server = server
        @retries = options.fetch(:retries, 5)
        @timeout = options.fetch(:timeout, 5)
        @interval = options.fetch(:interval, 0.5)
        @logger = options[:logger] || Calabash::Logger.new
        @on_error = {}
      end

      # @!visibility private
      def on_error(type, &block)
        @on_error[type] = block
      end

      # @!visibility private
      def change_server(new_server)
        @server = new_server
      end

      # Make an HTTP get request.
      #
      # This method takes multiple options.  If the option is not documented,
      # it should be considered _private_.  You use undocumented options at
      # your own risk.
      #
      # @param [Calabash::HTTP::Request] request The request.
      # @param [Hash] options Control the retry, timeout, and interval.
      # @option options [Number] :retries (5) How often to retry.
      # @option options [Number] :timeout (5) How long to wait for a response
      #  before timing out.
      # @option options [Number] :interval (0.5) How long to sleep between
      #  retries.
      def get(request, options={})
        request(request, :get, options)
      end

      # Make an HTTP post request.
      #
      # This method takes multiple options.  If the option is not documented,
      # it should be considered _private_.  You use undocumented options at
      # your own risk.
      #
      # @param [Calabash::HTTP::Request] request The request.
      # @param [Hash] options Control the retry, timeout, and interval.
      # @option options [Number] :retries (5) How often to retry.
      # @option options [Number] :timeout (5) How long to wait for a response
      #  before timing out.
      # @option options [Number] :interval (0.5) How long to sleep between
      #  retries.
      def post(request, options={})
        request(request, :post, options)
      end

      private

      def request(request, request_method, options={})
        retries = options.fetch(:retries, @retries)
        timeout = options.fetch(:timeout, @timeout)
        interval = options.fetch(:interval, @interval)
        header = HEADER.merge(options.fetch(:header, {}))

        @logger.log "Getting: #{@server.endpoint + request.route} #{options}"

        start_time = Time.now
        last_error = nil

        client = @client.dup
        client.receive_timeout = timeout

        retries.times do |i|
          first_try = i == 0

          # Subtract the aggregate time we've spent thus far to make sure we're
          # not exceeding the request timeout across retries.
          time_diff = start_time + timeout - Time.now

          if time_diff <= 0
            raise HTTP::Error, 'Timeout exceeded'
          end

          client.receive_timeout = [time_diff, client.receive_timeout].min

          begin
            if request_method == :get
              return client.send(request_method, @server.endpoint + request.route,
                                 request.params, header)
            else
              if request.params.is_a?(Hash)
                if request.params.key?(:json)
                  return client.send(request_method, @server.endpoint + request.route,
                                     {body: request.params[:json]}.merge(header: header))
                end
              end

              return client.send(request_method, @server.endpoint + request.route,
                                 {body: request.params}.merge(header: header))
            end
          rescue *RETRY_ON => e
            @logger.log "Http error: #{e}"

            if first_try
              if @on_error[e.class]
                @on_error[e.class].call(@server)
              end
            end

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
