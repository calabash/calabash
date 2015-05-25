module Calabash
  module IOS
    module Routes
      module MapRoute

        class MapRouteError < StandardError; end

        def map_route(query, method_name, *method_args)
          request = request(query, method_name, *method_args)
          response = post(request)
          handle_response(response, query)
        end

        private

        def make_map_parameters(query, method_name, *method_args)
          {
                :operation =>
                      {
                            :method_name => method_name,
                            :arguments => method_args
                      },
                :query => query
          }
        end

        def data(parameters)
          begin
            JSON.generate(parameters)
          rescue TypeError => e
            raise MapRouteError, "#{e}: could not generate JSON from '#{parameters}'"
          end
        end

        def request(query, method_name, *method_args)
          parameters = make_map_parameters(query, method_name, *method_args)
          data = data(parameters)
          Calabash::HTTP::Request.new('map', data)
        end

        def post(request)
          http_client.post(request)
        end

        def handle_response(response, query)
          body = response.body
          begin
            hash = JSON.parse(body)
          rescue TypeError, JSON::ParserError => e
            raise MapRouteError, "Could not parse response '#{body}: #{e}'"
          end

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              failure(hash, query)
            when 'SUCCESS'
              success(hash, query)
            else
              raise MapRouteError, "Server responded with an invalid outcome: '#{hash['outcome']}'"
          end
        end

        def failure(hash, query)

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
          raise MapRouteError, "Map failed reason: '#{reason}' details: '#{details}' for query '#{query}'"
        end

        def success(hash, query)
          Calabash::QueryResult.create(hash['results'], query)
        end
      end
    end
  end
end
