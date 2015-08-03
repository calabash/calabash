module Calabash
  module IOS
    # @!visibility private
    module Routes

      # @!visibility private
      module UIARouteMixin

        require 'run_loop'
        require 'edn'

        def uia_route(command)
          unless run_loop
            if defined?(IRB)
              logger.log('', :info)
              logger.log(Color.red('This console is not attached to a run-loop.'), :info)
              logger.log('', :info)
              logger.log(Color.green('If your have not launched your app yet, launch it with:'), :info)
              logger.log('', :info)
              logger.log(Color.cyan('> start_app'), :info)
              logger.log('', :info)
              logger.log('', :info)
              logger.log(Color.green('If your Calabash app is already running, ' \
                                     "you can attach to it's run-loop:"), :info)
              logger.log('', :info)
              logger.log(Color.cyan('> console_attach                # Attaches with the default strategy.'),
                         :info)
              logger.log(Color.cyan('> console_attach(uia_strategy)  # Attaches with a specific strategy.'),
                         :info)
              logger.log('', :info)
              logger.log('', :info)
              raise 'This console is not attached a run-loop.'
            else
              raise 'This device does not have a connection to run-loop.  Call start_app first.'
            end
          end

          strategy = uia_strategy

          case strategy
            when :preferences
              uia_over_http(command, 'uia')
            when :shared_element
              uia_over_http(command, 'uia-shared')
            when :host
              uia_over_host(command)
            else
              raise Calabash::IOS::RouteError, "Invalid :uia_strategy '#{strategy}'.  Valid strategies are: '#{UIA_STRATEGIES}"
          end
        end

        private

        UIA_STRATEGIES = [:preferences, :host, :shared_element]

        # Careful.  The UIA route can return all manner of weird responses.
        def uia_over_http(command, route)
          request = make_uia_request(command, route)
          response = route_post_request(request)
          parsed = parse_response_body(response)
          handle_uia_results(parsed['results'], command)
        end

        # Careful.  The UIA route can return all manner of weird responses.
        def uia_over_host(command)
          [RunLoop.send_command(run_loop, command)]
        end

        # Called _after_ route_handle_response or _after_ RunLoop.send_command
        def handle_uia_results(response, command)
          expect_uia_results_is_array(response)

          expect_uia_results_has_one_element(response)

          hash = response.first

          expect_uia_result_has_valid_status_key(hash, response, command)

          expect_uia_result_has_value_key(hash, response, command)

          status = hash['status']
          value = hash['value']

          if status == 'error'
            raise "Executing command '#{command}'\n" \
                    "resulted in an error: '#{value}'"
          else
            handle_uia_result_with_success(value)
          end
        end

        def expect_uia_results_is_array(response)
          if !response.is_a? Array
            raise "Expected '#{response}' to be an array."
          end
          response
        end

        def expect_uia_results_has_one_element(response)
          if response.length != 1
            raise "Expected '#{response}' to have exactly one element"
          end
          response
        end

        def expect_uia_response_element_is_hash(hash)
          if !hash.is_a? Hash
            raise "Expected first result of '#{hash}' to be a Hash"
          end
          hash
        end

        def expect_uia_result_has_valid_status_key(hash, response, command)
          status = hash['status']

          case status
            when 'error', 'success'
              hash
            else
              raise "Executing command '#{command}'\n" \
                    "returned an invalid status key: '#{status}'.\n" \
                    "Expected 'error' or 'success'.\n" \
                    "The raw response was '#{response}'"
          end
          hash
        end

        def expect_uia_result_has_value_key(hash, response, command)
          if !hash.has_key? 'value'
            raise "Executing command '#{command}'\n" \
                  "returned a value with no 'value' key.\n" \
                  "Then raw response was '#{response}'"
          end
          hash
        end

        def handle_uia_result_with_success(value)
          if value.is_a? Array
            value
          elsif value == ':nil'
            [nil]
          else
            [value]
          end
        end

        def make_uia_parameters(command)
          {
                :command => command
          }
        end

        def make_uia_request(command, route)
          parameters = make_uia_parameters(command)
          begin
            Calabash::HTTP::Request.request(route, parameters)
          rescue => e
            raise Calabash::IOS::RouteError, e
          end
        end

        def uia_serialize_and_call(uia_command, *query_args)
          command = uia_serialize_command(uia_command, *query_args)
          result = uia_route(command)
          result.first
        end

        # @todo Verify this is the correct way to escape '\n in string
        def uia_escape_string(string)
          Calabash::Text.escape_single_quotes(string).gsub("\n", "\\\\n")
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
