module Calabash
  module IOS
    # @!visibility private
    module Routes

      # @!visibility private
      module ResponseParser

        # @!visibility private
        def parse_response_body(response)
          body = response.body
          begin
            hash = JSON.parse(body)
          rescue TypeError, JSON::ParserError => e
            raise Calabash::IOS::RouteError, "Could not parse response '#{body}: #{e}'"
          end

          outcome = hash['outcome']

          case outcome
            when 'FAILURE'
              reason = hash['reason']
              if reason.nil? || reason.empty?
                hash['reason'] = 'Server provided no reason.'
              end

              details = hash['details']
              if details.nil? || details.empty?
                hash['details'] = 'Server provided no details.'
              end

            when 'SUCCESS'
              # Backdoor route returns a 'result' key.  Grr.
              # Legacy API: will be removed in Calabash iOS Server > 0.14.3
              if !(hash.has_key?('results') || hash.has_key?('result'))
                raise Calabash::IOS::RouteError, "Server responded with '#{outcome}'" \
                  "but response #{hash} does not contain 'results' key"
              end
            else
              raise Calabash::IOS::RouteError, 'Server responded with an invalid outcome:' \
                "'#{hash['outcome']}'"
          end
          hash
        end

      end
    end
  end
end
