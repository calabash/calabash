module Calabash
  module IOS
    # @!visibility private
    module Routes
      # @!visibility private
      module ConditionRouteMixin

        def condition_route(condition, timeout, query)
          request = make_condition_request(condition, timeout, query)
          response = route_post_request(request)
          handle_condition_response(response)
        end

        private

        #                         server
        #    key                  default   description
        # :condition    required
        # :timeout      optional     *     how long to wait
        # :duration     optional    0.2    time after which condition can be considered met
        # :frequency    optional    0.2    how often to check condition
        # :query           !        n/a    apply condition to matched views
        #
        # * => 6.0 for none animating and 30.0 for network indicator
        # ! => query is required for none animating!
        #
        # The :duration and :frequency are not part of the public API.
        def make_condition_parameters(condition, timeout, query)
          {
                :condition => condition,
                :timeout => timeout,
                :query => query
          }
        end

        def make_condition_request(condition, timeout, query)
          parameters = make_condition_parameters(condition, timeout, query)
          begin
            Calabash::HTTP::Request.request('condition', parameters)
          rescue => e
            raise Calabash::IOS::RouteError, e
          end
        end

        def handle_condition_response(response)
          hash = parse_response_body(response)

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              false
            when 'SUCCESS'
              true
            else
              nil
          end
        end
      end
    end
  end
end
