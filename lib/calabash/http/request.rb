module Calabash
  module HTTP
    class Request
      attr_reader :route, :params

      def initialize(route, params={})
        @route = route
        @params = params
      end

      # Create a new Request from `route` and `parameters`.
      #
      # @param [String] route The http route for the new request.
      # @param [Array, Hash] parameters An Array or Hash of parameters.
      # @return [Request] A new Request for `route` with `parameters`.
      # @raise [RequestError] Raises an error if the parameters cannot be
      #   converted to JSON
      def self.request(route, parameters)
        Request.new(route, Request.data(parameters))
      end

      private

      # Converts `parameters` to JSON.
      #
      # @param [Array, Hash] parameters An Array or Hash of parameters.
      # @return [String] A JSON formatted string that represents the parameters.
      # @raise [RequestError] Raises an error if the parameters cannot be
      #   converted to JSON
      def self.data(parameters)
        begin
          JSON.generate(parameters)
        rescue *[TypeError, JSON::GeneratorError] => e
          raise RequestError, "#{e}: could not generate JSON from '#{parameters}'"
        end
      end
    end
  end
end
