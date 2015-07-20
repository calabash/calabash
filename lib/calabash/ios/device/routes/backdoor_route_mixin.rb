module Calabash
  module IOS

    # @!visibility private
    class BackdoorError < StandardError;  end

    # @!visibility private
    module Routes
      # @!visibility private
      module BackdoorRouteMixin


        # @!visibility private
        def backdoor(selector_name, *arguments)
          request = make_backdoor_request(selector_name, arguments)
          response = route_post_request(request)
          handle_backdoor_response(selector_name, arguments, response)
        end

        private

        def make_backdoor_parameters(selector_name, arguments)
          if arguments.length > 1
            message = 'Calabash iOS does not support backdoor selectors with ' \
                      "more than one argument. Received #{arguments}"
            raise ArgumentError, message
          end

          if arguments.length < 1
            message = "Calabash iOS does not support backdoor selectors with no arguments."
            raise ArgumentError, message
          end

           unless selector_name.end_with?(':')
             messages =
               [
                 "Selector '#{selector_name}' is missing a trailing ':'",
                 'Valid backdoor selectors must take one argument.',
                 '',
                 'http://developer.xamarin.com/guides/testcloud/calabash/working-with/backdoors/#backdoor_in_iOS',
                 ''
               ]
               raise ArgumentError, messages.join("\n")
           end

          {
             :selector => selector_name,
             :arg => arguments.first
          }
        end

        def make_backdoor_request(selector_name, arguments)
           parameters = make_backdoor_parameters(selector_name, arguments)
          begin
            Calabash::HTTP::Request.request('backdoor', parameters)
          rescue => e
            raise RouteError, e
          end
        end

        def handle_backdoor_response(selector_name, arguments, response)
          body = response.body
          begin
            hash = JSON.parse(body)
          rescue TypeError, JSON::ParserError => e
            raise RouteError, "Could not parse response '#{body}: #{e}'"
          end

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              message = "Calling backdoor '#{selector_name}' with arguments '#{arguments}'" \
                "failed because:\n\n#{hash['reason']}\n#{hash['details']}"
              raise Calabash::IOS::BackdoorError, message
            when 'SUCCESS'
              return hash['result']
            else
              raise RouteError, "Server responded with an invalid outcome: '#{hash['outcome']}'"
          end
        end
      end
    end
  end
end

