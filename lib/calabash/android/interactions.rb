require 'date'
require 'time'

module Calabash
  module Android

    # Interactions with your app that are specific to Android.
    module Interactions
      # Go back. If the keyboard is shown, it will be dismissed.
      def go_back
        Calabash::Internal.with_default_device(required_os: :android) do |device|
          device.perform_action('hide_soft_keyboard')
        end

        press_physical_back_button
      end

      # Go to the home screen.
      def go_home
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.go_home}

        true
      end

      # Get the name of the currently focused activity
      #
      # @example
      #  puts focused_activity
      #  # => com.example.MainActivity
      #
      # @return [String] The name of the currently focused activity.
      def focused_activity
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.current_focus[:activity]}
      end

      # Get the name of the currently focused package
      #
      # @example
      #  puts focused_package
      #  # => com.example
      #
      # @return [String] The name of the currently focused package
      def focused_package
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.current_focus[:package]}
      end

      # Sets the date of the first visible date picker widget.
      #
      # @example
      #  set_date('2012-04-24')
      #
      # @example
      #  date = Date.parse('3rd Feb 2012')
      #  set_date(date)
      #
      # @param [Date, String] date The date to set. If given a String,
      #  `Date.parse` is called on the string.
      #
      # @see #set_date_in
      def set_date(date)
        set_date_in("android.widget.DatePicker index:0", date)
      end

      # Sets the date of a date picker widget. If `query` matches multiple date
      # pickers, the date is set for all of them.
      #
      # @param [String, Hash, Calabash::Query] query The query to match the
      #  date picker.
      # @param [Date, String] date The date to set. If given a String,
      #  `Date.parse` is called on the string.
      # @see #set_date
      def set_date_in(query, date)
        if date.is_a?(String)
          date = Date.parse(date)
        end

        wait_for_view(query, timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)
        result = query(query, updateDate: [date.year, date.month, date.day])

        if result.length != 1
          raise "Failed to set the date of '#{query}'"
        end

        if result.first.is_a?(Hash) && result.first.has_key?('error')
          raise result.first['error']
        end

        true
      end

      # Sets the time of the first visible time picker widget.
      #
      # @example
      #  set_time('14:42')
      #
      # @example
      #  time = Time.parse('8:30 AM')
      #  set_time(time)
      #
      # @param [Time, String] time The time to set. If given a String,
      #  `Time.parse` is called on the string.
      #
      # @see #set_time_in
      def set_time(time)
        set_time_in("android.widget.TimePicker index:0", time)
      end

      # Sets the time of a time picker widget. If `query` matches multiple time
      # pickers, the time is set for all of them.
      #
      # @param [String, Hash, Calabash::Query] query The query to match the
      #  time picker.
      # @param [Time, String] time The time to set. If given a String,
      #  `Time.parse` is called on the string.
      # @see #set_time
      def set_time_in(query, time)
        if time.is_a?(String)
          time = Time.parse(time)
        end

        wait_for_view(query, timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)
        result = query(query, setCurrentHour: time.hour)

        if result.length != 1
          raise "Failed to set the time of '#{query}'"
        end

        if result.first.is_a?(Hash) && result.first.has_key?('error')
          raise result.first['error']
        end

        result = query(query, setCurrentMinute: time.min)

        if result.length != 1
          raise "Failed to set the time of '#{query}'"
        end

        if result.first.is_a?(Hash) && result.first.has_key?('error')
          raise result.first['error']
        end

        true
      end
    end
  end
end
