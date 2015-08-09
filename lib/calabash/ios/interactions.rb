module Calabash
  module IOS

    # Interactions with your app that are specific to iOS
    module Interactions

      # @!visibility private
      # Sends app to background. Simulates pressing the home button.
      #
      # @note Cannot be more than 60 seconds.
      #
      # @param [Numeric] seconds The number of seconds to keep the app
      #   in the background
      # @raise [ArgumentError] If number of seconds is less than 1 and more
      #   than 60 seconds.
      def _send_current_app_to_background(seconds)
        unless (1..60).member?(seconds)
          raise ArgumentError,
            "Number of seconds: '#{seconds}' must be between 1 and 60"
        end

        javascript = %Q(
          var x = target.deactivateAppForDuration(#{seconds});
          var MAX_RETRY=5, retry_count = 0;
          while (!x && retry_count < MAX_RETRY) {
            x = target.deactivateAppForDuration(#{seconds});
            retry_count += 1
          };
          x
        )
        uia(javascript)
      end

      # @!visibility private
      def _evaluate_javascript_in(query, javascript)
        query(query, calabashStringByEvaluatingJavaScript: javascript)
      end
    end
  end
end
