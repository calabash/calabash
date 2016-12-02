require 'date'

module Calabash
  module IOS

    # A collection of methods for interacting with UIDatePicker.
    module DatePicker

      # The API has been tested in various time zones and tested
      # once while crossing the international date line (on a boat).
      # With that said, the API makes some assumptions about locales
      # and time zones.  It is possible to customize the ruby date
      # format and Objective-C date format to get the behavior you
      # need.  You will need to monkey patch the following methods:
      #
      #  * date_picker_ruby_date_format
      #  * date_picker_objc_date_format
      #
      # Before going down this path, we recommend that you ask for
      # advice on the Calabash support channels.

      # @!visibility private
      # Provided for monkey patching, but not part of the public API.
      def date_picker_ruby_date_format
        RUBY_DATE_AND_TIME_FMT
      end

      # @!visibility private
      # Provided for monkey patching, but not part of the public API.
      def date_picker_objc_date_format
        OBJC_DATE_AND_TIME_FMT
      end

      # @!visibility private
      # Returns the picker mode of the first UIDatePicker match by `query`.
      #
      # @see #time_mode?
      # @see #date_mode?
      # @see #date_and_time_mode?
      # @see #countdown_mode?
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      # @return [String] Returns the picker mode which will be one of
      #  `{'0', '1', '2', '3'}`
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If an unknown mode is returned.
      # @raise [RuntimeError] If first view matched by query does not responde
      #   to 'datePickerMode'.
      def date_picker_mode(query)
        Query.ensure_valid_query(query)

        message = "Timed out waiting for picker with #{query}"
        mode = nil

        wait_for(message) do
          result = query(query, :datePickerMode)
          if result.empty?
            false
          else
            mode = result.first
            if [0, 1, 2, 3].include?(mode)
              mode
            else
              if mode == '*****'
                raise RuntimeError,
                  "Query #{query} matched a view that does not respond 'datePickerMode'"
              else
                raise RuntimeError,
                  "Query #{query} returned an unknown mode '#{mode}' for 'datePickerMode'"
              end
            end
          end
        end
      end

      # Is the date picker in time mode?
      #
      # @see #time_mode?
      # @see #date_mode?
      # @see #date_and_time_mode?
      # @see #countdown_mode?
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [Boolean] True if the picker is in time mode.
      #
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If an unknown mode is returned.
      # @raise [RuntimeError] If first view matched by query does not responde
      #   to 'datePickerMode'.
      def time_mode?(query)
        date_picker_mode(query) == UI_DATE_PICKER_MODE_TIME
      end

      # Is the date picker in date mode?
      #
      # @see #time_mode?
      # @see #date_mode?
      # @see #date_and_time_mode?
      # @see #countdown_mode?
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [Boolean] True if the picker is in date mode.
      #
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If an unknown mode is returned.
      # @raise [RuntimeError] If first view matched by query does not responde
      #   to 'datePickerMode'.
      def date_mode?(query)
        date_picker_mode(query) == UI_DATE_PICKER_MODE_DATE
      end

      # Is the date picker in date and time mode?
      #
      # @see #time_mode?
      # @see #date_mode?
      # @see #date_and_time_mode?
      # @see #countdown_mode?
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [Boolean] True if the picker is in date and time mode.
      #
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If an unknown mode is returned.
      # @raise [RuntimeError] If first view matched by query does not responde
      #   to 'datePickerMode'.
      def date_and_time_mode?(query)
        date_picker_mode(query) == UI_DATE_PICKER_MODE_DATE_AND_TIME
      end

      # Is the date picker in countdown mode?
      #
      # @see #time_mode?
      # @see #date_mode?
      # @see #date_and_time_mode?
      # @see #countdown_mode?
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [Boolean] True if the picker is in countdown mode.
      #
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If an unknown mode is returned.
      # @raise [RuntimeError] If first view matched by query does not responde
      #   to 'datePickerMode'.
      def countdown_mode?(query)
        date_picker_mode(query) == UI_DATE_PICKER_MODE_COUNT_DOWN_TIMER
      end

      # The maximum date for a picker.  If there is no maximum date, this
      # method returns nil.
      #
      # @note
      #  From the Apple docs:
      #  `The property is an NSDate object or nil (the default)`.
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [DateTime] The maximum date on the picker or nil if no maximum
      #  exists
      #
      # @raise [RuntimeError] If the picker is in countdown mode.
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If the date returned by the server cannot be
      #   converted to a DateTime object.
      def maximum_date_time_from_picker(query)
        Query.ensure_valid_query(query)

        wait_for_view(query)

        if countdown_mode?(query)
          fail('Countdown pickers do not have a maximum date.')
        end

        result = query(query, :maximumDate)

        if result.empty?
          fail("Expected '#{query}' to return a visible UIDatePicker")
        else
          if result.first.nil?
            nil
          else
            date_str = result.first
            begin
              date_time = DateTime.parse(date_str)
            rescue TypeError, ArgumentError => _
              raise RuntimeError,
                "Could not convert string '#{date_str}' into a valid DateTime object"
            end
            date_time
          end
        end
      end

      # The minimum date for a picker.  If there is no minimum date, this
      # method returns nil.
      #
      # @note
      #  From the Apple docs:
      #  `The property is an NSDate object or nil (the default)`.
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [DateTime] The minimum date on the picker or nil if no minimum
      #  exists
      #
      # @raise [RuntimeError] If the picker is in countdown mode.
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If the date returned by the server cannot be
      #   converted to a DateTime object.
      def minimum_date_time_from_picker(query)
        Query.ensure_valid_query(query)

        wait_for_view(query)

        if countdown_mode?(query)
          fail('Countdown pickers do not have a minimum date.')
        end

        result = query(query, :minimumDate)

        if result.empty?
          fail("Expected '#{query}' to return a visible UIDatePicker")
        else
          if result.first.nil?
            nil
          else
            date_str = result.first
            begin
              date_time = DateTime.parse(date_str)
            rescue TypeError, ArgumentError => _
              raise RuntimeError,
                "Could not convert string '#{date_str}' into a valid DateTime object"
            end
            date_time
          end
        end
      end

      # Returns the date and time from the picker as DateTime object.
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      #
      # @return [DateTime] The date on the picker
      #
      # @raise [RuntimeError] If the picker is in countdown mode.
      # @raise [RuntimeError] If no picker can be found.
      # @raise [RuntimeError] If the date returned by the server cannot be
      #   converted to a DateTime object.
      def date_time_from_picker(query)
        Query.ensure_valid_query(query)

        wait_for_view(query)

        if countdown_mode?(query)
          fail('This method is available for pickers in countdown mode.')
        end

        result = query(query, :date)

        if result.empty?
          fail("Expected '#{query}' to return a visible UIDatePicker")
        else
          if result.first.nil?
            nil
          else
            date_str = result.first
            date_time = DateTime.parse(date_str)
            if date_time.nil?
              raise RuntimeError,
                "Could not convert string '#{date_str}' into a valid DateTime object"
            end
            date_time
          end
        end
      end

      # Sets the date and time on the _first_ UIDatePicker matched by
      # `query`.
      #
      # This method is not valid for UIDatePickers in _countdown_ mode.
      #
      # @param [DateTime] date_time The date and time you want to change to.
      #
      # @raise [RuntimeError] If `query` does match exactly one picker.
      # @raise [RuntimeError] If `query` matches a picker in countdown mode.
      # @raise [RuntimeError] If the target date is greater than the picker's
      #  maximum date.
      # @raise [RuntimeError] If the target date is less than the picker's
      #  minimum date
      # @raise [ArgumentError] If the target date is not a DateTime instance.
      def picker_set_date_time(date_time)
        picker_set_date_time_in("UIDatePicker index:0", date_time)
      end

      # Sets the date and time on the _first_ UIDatePicker matched by
      # `query`.
      #
      # This method is not valid for UIDatePickers in _countdown_ mode.
      #
      # An error will be raised if more than on view is matched by `query`.
      #
      # To avoid matching more than one UIPickerView or subclass:
      #  * Make the query more specific:    "UIPickerView marked:'alarm'"
      #  * Use the index language feature:  "UIPickerView index:0"
      #  * Query by custom class:           "view:'MyPickerView'"
      #
      # @param [String, Hash, Calabash::Query] query A query that can be used
      #   to find UIDatePickers.
      # @param [DateTime] date_time The date and time you want to change to.
      #
      # @raise [RuntimeError] If `query` does match exactly one picker.
      # @raise [RuntimeError] If `query` matches a picker in countdown mode.
      # @raise [RuntimeError] If the target date is greater than the picker's
      #  maximum date.
      # @raise [RuntimeError] If the target date is less than the picker's
      #  minimum date
      # @raise [ArgumentError] If the target date is not a DateTime instance.
      def picker_set_date_time_in(query, date_time)
        unless date_time.is_a?(DateTime)
          raise ArgumentError,
            "Date time argument '#{date_time}' must be a DateTime but found '#{date_time.class}'"
        end

        Query.ensure_valid_query(query)

        message = "Timed out waiting for UIDatePicker with '#{query}'"

        wait_for(message) do
          result = query(query)
          if result.length > 1
            fail("Query '#{query}' matched more than on UIDatePicker")
          else
            !result.empty?
          end
        end

        if countdown_mode?(query)
          message =
            [
              "Query '#{query}' matched a picker in countdown mode.",
              'Setting the date or time on a countdown picker is not supported'
            ].join("\n")
          fail(message)
        end

        minimum_date = minimum_date_time_from_picker(query)
        if !minimum_date.nil? && minimum_date > date_time
          message = [
            "Cannot set the date on the picker matched by '#{query}'",
            "Picker minimum date:  '#{minimum_date}'",
            "  Date to change to:  '#{date_time}'",
            "Target date comes before the minimum date."].join("\n")
          fail(message)
        end

        maximum_date = maximum_date_time_from_picker(query)
        if !maximum_date.nil? && maximum_date < date_time
          message = [
            "Cannot set the date on the picker matched by '#{query}'",
            "Picker maximum date:  '#{maximum_date}'",
            "  Date to change to:  '#{date_time}'",
            "Target date comes after the maximum date."].join("\n")
          fail(message)
        end

        ruby_format = date_picker_ruby_date_format
        objc_format = date_picker_objc_date_format
        target_date_string = date_time.strftime(ruby_format).squeeze(' ').strip

        Calabash::Internal.with_current_target(required_os: :ios) do |target|
          target.map_route(query,
                           :changeDatePickerDate,
                           target_date_string,
                           objc_format,
                           # notify targets
                           true,
                           # animate
                           true)
        end
      end

      private

      # @!visibility private
      OBJC_DATE_AND_TIME_FMT = 'yyyy_MM_dd_HH_mm'

      # @!visibility private
      RUBY_DATE_AND_TIME_FMT = '%Y_%m_%d_%H_%M'

      # UIDatePicker modes

      # @!visibility private
      UI_DATE_PICKER_MODE_TIME = 0
      # @!visibility private
      UI_DATE_PICKER_MODE_DATE = 1
      # @!visibility private
      UI_DATE_PICKER_MODE_DATE_AND_TIME = 2
      # @!visibility private
      UI_DATE_PICKER_MODE_COUNT_DOWN_TIMER = 3
    end
  end
end

