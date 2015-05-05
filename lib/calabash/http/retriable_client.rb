require 'httpclient'
require 'retriable'

module Calabash
  module HTTP
    class RetriableClient
      attr_reader :client

      def initialize(server, options = {})
        @client = options[:client] || ::HTTPClient.new
        @server = server
        @retries = options.fetch(:retries, 5)
        @timeout = options.fetch(:timeout, 5)
        @interval = options.fetch(:interval, 0.5)
      end

      def get(request, options={})
        retries = options.fetch(:retries, @retries)
        timeout = options.fetch(:timeout, @timeout)
        interval = options.fetch(:interval, @interval)

        intervals = Array.new(retries, interval)
        begin
          Retriable.retriable(intervals: intervals, timeout: timeout) do
            @client.get(@server.endpoint + request.route, request.params)
          end
        rescue => e
          raise HTTP::Error.new(e.message)
        end
      end
    end
  end
end
