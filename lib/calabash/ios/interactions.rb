module Calabash
  module IOS
    module Interactions
      # Currently two conditions that can be
      # waited for using `wait_for_condition`: `:none_animating` no UIKit object is animating
      # and `:no_network_indicator` status bar network indicator not showing.
      CALABASH_CONDITIONS = {:none_animating => 'NONE_ANIMATING',
                             :no_network_indicator => 'NO_NETWORK_INDICATOR'}

      # Waits for all elements to stop animating (EXPERIMENTAL).
      # @param [Hash] options options for controlling the details of the wait.
      # @option options [Numeric] :timeout (30) maximum time to wait
      # @return [nil] when the condition is satisfied
      # @raise [Calabash::Cucumber::WaitHelpers::WaitError] when the timeout is exceeded
      def wait_for_none_animating
        wait_for_condition(CALABASH_CONDITIONS[:none_animating])
      end

      # Waits for the status-bar network indicator to stop animating (network activity done).
      # @param [Hash] options options for controlling the details of the wait.
      # @option options [Numeric] :timeout (30) maximum time to wait
      # @return [nil] when the condition is satisfied
      # @raise [Calabash::Cucumber::WaitHelpers::WaitError] when the timeout is exceeded
      def wait_for_no_network_indicator
        wait_for_condition(CALABASH_CONDITIONS[:no_network_indicator])
      end

      CLIENT_TIMEOUT_ADDITION = 5

      def wait_for_condition(condition)
        with_timeout(Calabash::Wait.default_options[:timeout]+CLIENT_TIMEOUT_ADDITION, "Timed out waiting for condition '#{condition}'") do
          Device.default.wait_for_condition(query: '*', condition: condition)
        end
      end
    end
  end
end
