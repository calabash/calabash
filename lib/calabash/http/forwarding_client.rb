module Calabash
  module HTTP
    class ForwardingClient
      HEADER_FORWARD = 'X-FORWARD-PORT'
      ROUTES = [:get, :post, :put, :delete]

      def initialize(client, forward_to_port)
        @client = client
        @forward_to_port = forward_to_port
      end

      ROUTES.each do |route|
        define_method(route) do |request, options = {}|
          new_options = options.clone
          new_options[:header] ||= {}
          new_options[:header][HEADER_FORWARD] = @forward_to_port.to_s

          @client.send(route, request, new_options)
        end
      end
    end
  end
end
