module Calabash
  module IOS
    module Routes
      module UIARoute

        require 'run_loop'

        def uia_route(command)
          unless run_loop
            raise RouteError, 'This device does not have a connection to run-loop.  Call start_app first.'
          end

          strategy = uia_strategy

          case strategy
            when :preferences, :shared_element
              uia_over_preferences(command)
            when :host
              uia_over_host(command)
            else
              raise RouteError, "Invalid :uia_strategy '#{strategy}'.  Valid strategies are: '#{UIA_STRATEGIES}"
          end
        end

        private

        UIA_STRATEGIES = [:preferences, :host, :shared_element]

        # Careful.  The UIA route can return all manner of weird responses.
        def uia_over_preferences(command)
          request = make_uia_request(command)
          response = route_post_request(request)
          route_handle_response(response, command)
        end

        # Careful.  The UIA route can return all manner of weird responses.
        def uia_over_host(command)
          RunLoop.send_command(run_loop, command)
        end

        def make_uia_parameters(command)
          {
                :command => command
          }
        end

        def make_uia_request(command)
          parameters = make_uia_parameters(command)
          begin
            Calabash::HTTP::Request.request('uia', parameters)
          rescue => e
            raise RouteError, e
          end
        end

        # @todo Move this to somewhere public.
        # Escapes single quotes in `string`.
        #
        # @example
        #   > escape_quotes("Let's get this done.")
        #   => "Let\\'s get this done."
        # @param [String] string The string to escape.
        # @return [String] A string with its single quotes properly escaped.
        def escape_single_quotes(string)
          string.gsub("'", "\\\\'")
        end

      end
    end
  end
end
