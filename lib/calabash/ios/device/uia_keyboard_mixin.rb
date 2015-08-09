module Calabash
  module IOS

    # @!visibility private
    module UIAKeyboardMixin

      # @param [Hash] options Control behavior of this method.
      # @option options [String] :existing_text ('') Text that exists in the
      #  view before this method is called.  Passing this option ensures that
      #  the existing text is _appended_ rather than cleared and helps the
      #  underlying JavaScript handle various bugs in UIAutomation's
      #  typeString JavaScript API.
      # @option options [Boolean] :escape_backslashes (true) When try, this
      #  method escapes '\'  characters in the `string` before sending the
      #  string over UIA.  The only time you don't want to escape the '\'
      #  character is when you are trying to send a single character like '\n'
      #  or '\d'.
      def uia_type_string(string, options={})
        default_options =
              {
                    existing_text: '',
                    escape_backslashes: true
              }
        merged_options = default_options.merge(options)

        if merged_options[:escape_backslashes]
          string_to_type = UIATypeStringHandler.escape_backslashes_in_string(string)
        else
          string_to_type = string.dup
        end

        existing_text = merged_options[:existing_text]

        result = uia_serialize_and_call(:typeString, string_to_type, existing_text)

        handler = uia_type_string_handler(string,
                                          string_to_type,
                                          existing_text,
                                          result,
                                          logger)
        handler.handle_result
      end

      private

      # @!visibility private
      def uia_type_string_handler(string, escaped_string, existing_text, result, logger)
        UIATypeStringHandler.new(string,
                                 escaped_string,
                                 existing_text,
                                 result,
                                 logger)
      end

      # @!visibility private
      class UIATypeStringHandler

        attr_reader :string, :escaped_string, :existing_text, :result, :logger

        # The result returned should be a Hash.
        #
        # The result should have these keys.  The 'value' key may or may not
        # exist.  The range of the 'value' key is not well understood; it varies
        # depending on the context in which you are typing.
        #
        # :status => 'success' or 'error'
        # :value => A hash of the view that was typed in, :nil', or nil.
        # :index => This value is not important; ignore it.
        def initialize(string, escaped_string, existing_text, result, logger)
          @string = string
          @escaped_string = escaped_string
          @existing_text = existing_text
          @result = result
          @logger = logger
        end

        # @!visibility private
        def self.escape_backslashes_in_string(string)
          return string if string.index(/\\/)

          escaped_string = string.dup

          indexes = escaped_string.enum_for(:scan, /\\/).map { Regexp.last_match.begin(0) }
          indexes.reverse.each { |idx| escaped_string = escaped_string.insert(idx, '\\') }

          escaped_string
        end

        # Valid values: 'success' or 'error'
        def status
          result['status']
        end

        # A Hash of the view that was typed in or :nil.  Other values are
        # possible, but we don't have an enumeration of the possible values.
        def value
          result['value']
        end

        # @!visibility private
        def log(message)
          logger.log(Color.blue(message), :info)
        end

        # @!visibility private
        def log_preamble
          log('When typing:')
          log("   raw string: #{string}")
          log("      escaped: #{escaped_string}")
          log("existing text: #{existing_text}")
        end

        # @!visibility private
        def log_epilogue
          log("       result: #{result}")
          log('')
          log('Please report this!')
          log('https://github.com/calabash/calabash-ios/issues/374')
        end

        # @!visibility private
        def handle_result
          the_status = status
          if the_status == 'error'
            handle_error
          elsif the_status == 'success'
            handle_success
          elsif result.is_a? Hash
            if ['label', 'hit-point', 'el', 'rect'].all? { |key| result.has_key?(key) }
              result
            else
              handle_unknown_status
            end
          else
            handle_unknown_status
          end
        end

        # @!visibility private
        def handle_error
          log_preamble
          if result.has_key? 'value'
            raise "Could not type '#{string}' - UIAutomation returned an error: '#{result['error']}'"
          else
            raise "Could not type '#{string}' - UIAutomation returned '#{result}'"
          end
        end

        # When 'status' == 'success', we can get a variety of valid 'values'
        #
        # For example, typing on UIWebViews returns['value'] => ':nil'.
        #
        # The expected value is a Hash representation of the view that was
        # typed in.
        #
        # We are interested in loggin situations where:
        #
        # 1. The 'value' key is not present in the result.
        # 2. The 'value' key has a nil value.
        def handle_success
          the_value = value
          if the_value.is_a? Hash
            the_value
          elsif the_value == ':nil'
            true
          else
            handle_success_with_incident
          end
        end

        # @!visibility private
        def handle_success_with_incident
          log_preamble
          if value.nil?
            if result.has_key? 'value'
              log("received a 'success' response with no key for 'value'")
            else
              log("received a 'success' response with a 'nil' for key 'value'")
            end
          else
            log("received a 'success' response with an unknown value for key 'value' => '#{value}'")
          end
          log_epilogue
          false
        end

        # @!visibility private
        def handle_unknown_status
          log_preamble
          log("receive response with an unknown value for 'status' key: '#{status}'")
          log_epilogue
          false
        end
      end
    end
  end
end
