module Calabash
  module Android
    module Interactions
      # Go back.
      def go_back
        Device.default.perform_action('hide_soft_keyboard')
        press_back_button
      end

      # Go to the home screen.
      def go_home
        Device.default.go_home

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
        Device.default.current_focus[:activity]
      end

      # Get the name of the currently focused package
      #
      # @example
      #  puts focused_package
      #  # => com.example
      #
      # @return [String] The name of the currently focused package
      def focused_package
        Device.default.current_focus[:package]
      end

      # @!visibility private
      def _evaluate_javascript_in(query, javascript)
        Device.default.evaluate_javascript_in(query, javascript)
      end
    end
  end
end
