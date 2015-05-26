module Calabash
  module IOS
    module Routes
      module UIARoute

        require 'run_loop'
        require 'edn'

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

        def uia_serialize_and_call(uia_command, *query_args)
          command = uia_serialize_command(uia_command, *query_args)
          result = uia_route(command)
          result.first
        end

        # @todo Move this to somewhere public because it is useful to users.
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

        # @todo Verify this is the correct way to escape '\n in string
        def uia_escape_string(string)
          escape_single_quotes(string).gsub("\n", "\\\\n")
        end

        def uia_serialize_argument(part)
          if part.is_a?(String)
            "'#{uia_escape_string(part)}'"
          else
            "'#{uia_escape_string(part.to_edn)}'"
          end
        end

        def uia_serialize_arguments(argument_array)
          argument_array.map do |part|
            uia_serialize_argument(part)
          end
        end

        def uia_serialize_command(uia_command, *query_args)
          args = uia_serialize_arguments(query_args)
          %Q[uia.#{uia_command}(#{args.join(', ')})]
        end

        # @todo Move to a translate mixin (or helper)
        # @todo No unit tests for this yet!
        def uia_center_of_view(view_hash)
          rect = view_hash['rect']

          # Why would the view hash not have a rect?
          unless rect
            raise "Expected '#{view_hash}' to have a 'rect' key"
          end
          {:x => rect['center_x'], :y => rect['center_y']}
        end

        # @todo Move to a translate mixin (or helper)
        # def point_from(query_result, options={})
        #   offset_x = 0
        #   offset_y = 0
        #   if options[:offset]
        #     offset_x += options[:offset][:x] || 0
        #     offset_y += options[:offset][:y] || 0
        #   end
        #   x = offset_x
        #   y = offset_y
        #   rect = query_result['rect'] || query_result[:rect]
        #   if rect
        #     x += rect['center_x'] || rect[:center_x] || rect[:x] || 0
        #     y += rect['center_y'] || rect[:center_y] || rect[:y] || 0
        #   else
        #     x += query_result['center_x'] || query_result[:center_x] || query_result[:x] || 0
        #     y += query_result['center_y'] || query_result[:center_y] || query_result[:y] || 0
        #   end
        #
        #   {:x => x, :y => y}
        # end

        # @todo Is this worth keeping?
        # def uia_result(s)
        #   query_result = s.first
        #   if query_result['status'] == 'success'
        #     query_result['value']
        #   else
        #     query_result['status']
        #   end
        # end
      end
    end
  end
end
