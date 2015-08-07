module Calabash
  module IOS
    # @!visibility private
    module Routes
      # @!visibility private
      module HandleRouteMixin

        private

        def route_post_request(request)
          begin
            if request.params[/\"method_name\":\"flash\"/, 0]
              http_client.post(request, timeout: 30)
            else
              http_client.post(request)
            end
          rescue => e
            raise Calabash::IOS::RouteError, e
          end
        end

        def route_handle_response(response, query)
          hash = parse_response_body(response)

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              route_failure(hash, query)
            when 'SUCCESS'
              route_success(hash, query)
            else
              raise Calabash::IOS::RouteError, "Server responded with an invalid outcome: '#{hash['outcome']}'"
          end
        end

        def route_failure(hash, query)

          fetch_value = lambda do |key|
            value = hash[key]
            if value.nil? || value.empty?
              'unknown'
            else
              value
            end
          end

          reason = fetch_value.call('reason')
          details = fetch_value.call('details')
          raise Calabash::IOS::RouteError, "Map failed reason: '#{reason}' details: '#{details}' for query '#{query}'"
        end

        # TODO: handle invalid results
        #
        # So far, cases like this have been handled individually.
        #
        # Briar tests the 0.x behavior for every map call.
        #
        # These are the docs from 0.x assert_map_results
        #
        #  # Asserts the result of a calabash `map` call and raises an error with
        #  # `msg` if no valid results are found.
        #  #
        #  # Casual gem users should never need to call this method; this is a
        #  # convenience method for gem maintainers.
        #  #
        #  # Raises an error if `map_results`:
        #  #
        #  #              is an empty list #=> []
        #  #    contains a '<VOID>' string #=> [ "<VOID>" ]
        #  #       contains '*****' string #=> [ "*****"  ]
        #  #         contains a single nil #=> [ nil ]
        #  #
        #  # When evaluating whether a `map` call is successful it is important to
        #  # note that sometimes a <tt>[ nil ]</tt> or <tt>[nil, <val>, nil]</tt> is
        #  # a valid result.
        #  #
        #  # Consider a controller with 3 labels:
        #  #
        #  #    label @ index 0 has text "foo"
        #  #    label @ index 1 has text nil (the [label text] => nil)
        #  #    label @ index 2 has text "bar"
        #  #
        #  #    map('label', :text) => ['foo', nil, 'bar']
        #  #    map('label index:1', :text) => [nil]
        #  #
        #  # In other cases, <tt>[ nil ]</tt> should be treated as an invalid result
        #  #
        #  #    # invalid
        #  #    > mark = 'mark does not exist'
        #  #    > map('tableView', :scrollToRowWithMark, mark, args) => [ nil ]
        #  #
        #  # Here a <tt>[ nil ]</tt> should be considered invalid because the
        #  # the operation could not be performed because there is not row that
        #  # matches `mark`
        def route_success(hash, query)
          if query.nil?
            hash['results']
          else
            Calabash::QueryResult.create(hash['results'], query)
          end
        end
      end
    end
  end
end
