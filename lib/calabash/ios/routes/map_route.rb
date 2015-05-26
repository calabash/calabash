module Calabash
  module IOS
    module Routes
      module MapRoute

        def map_route(query, method_name, *method_args)
          request = make_map_request(query, method_name, *method_args)
          response = route_post_request(request, MapRouteError)
          route_handle_response(response, query, MapRouteError)
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

        def make_map_request(query, method_name, *method_args)
          parameters = make_map_parameters(query, method_name, *method_args)
          begin
            Calabash::HTTP::Request.request('map', parameters)
          rescue => e
            raise MapRouteError, e
          end
        end
      end
    end
  end
end
