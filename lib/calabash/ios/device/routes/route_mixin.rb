module Calabash
  module IOS
    module Routes
      module RouteMixin

        private

        def route_post_request(request)
          begin
            http_client.post(request)
          rescue => e
            raise RouteError, e
          end
        end

        def route_handle_response(response, query)
          body = response.body
          begin
            hash = JSON.parse(body)
          rescue TypeError, JSON::ParserError => e
            raise RouteError, "Could not parse response '#{body}: #{e}'"
          end

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              route_failure(hash, query)
            when 'SUCCESS'
              route_success(hash, query)
            else
              raise RouteError, "Server responded with an invalid outcome: '#{hash['outcome']}'"
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
          raise RouteError, "Map failed reason: '#{reason}' details: '#{details}' for query '#{query}'"
        end

        def route_success(hash, query)
          Calabash::QueryResult.create(hash['results'], query)
        end
      end
    end
  end
end