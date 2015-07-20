module Calabash
  module IOS
    module Conditions

      # Waits for all elements to stop animating.
      #
      # @param [Numeric] timeout How long to wait for the animations to stop.
      # @return [nil] when the condition is satisfied
      # @raise [Calabash::Cucumber::WaitHelpers::WaitError] when the timeout is exceeded
      def wait_for_none_animating(timeout=2)
        message = "Timed out after #{timeout} seconds wait for all views to stop animating."

        wait_for_condition(CALABASH_CONDITIONS[:none_animating],
                           timeout,
                           message,
                           query)
      end

      # Waits for all elements matching `query` to stop animating.
      #
      # @param [String] query The view to wait for.
      # @param [Numeric] timeout How long to wait for the animations to stop.
      # @return [nil] When the condition is satisfied.
      # @raise [Calabash::Wait::TimeoutError] When the timeout is exceeded.
      def wait_for_animations(query, timeout=2)

        if query.nil? || query == ''
          raise ArgumentError, 'Query argument must not be nil or the empty string'
        end

        message = "Timed out after #{timeout} waiting for views matching '#{query}' to stop animating."

        wait_for_condition(CALABASH_CONDITIONS[:none_animating],
                           timeout,
                           message,
                           query)
      end

      # Waits for the status-bar network indicator to stop animating
      # (network activity done).
      #
      # param [Numeric] timeout How long to wait for the animations to stop.
      # @return [nil] When the condition is satisfied.
      # @raise [Calabash::Wait::TimeoutError] When the timeout is exceeded.
      def wait_for_no_network_indicator(timeout=15)
        message = "Timed out after #{timeout} waiting for the network indicator to stop animating."

        wait_for_condition(CALABASH_CONDITIONS[:no_network_indicator],
                           timeout,
                           message)
      end

      private

      CALABASH_CONDITIONS = {:none_animating => 'NONE_ANIMATING',
                             :no_network_indicator => 'NO_NETWORK_INDICATOR'}

      # @!visibility private
      #
      # Waits for condition.
      #
      # @param [String] condition The condition to wait for.
      # @param [Numeric] timeout How long to wait.
      # @param [String] timeout_message The message used when raising an error if
      #  the condition is not satisfied.
      # @param [String] query Views matching this query will have the condition
      #  applied to them.  Will be ignored for some conditions e.g.
      #  NO_NETWORK_INDICATOR
      # @return [nil] When the condition is satisfied.
      # @raise [Calabash::Wait::TimeoutError] When the timeout is exceeded.
      def wait_for_condition(condition, timeout, timeout_message, query=nil)
        unless Device.default.condition_route(condition, timeout, query)
          raise Calabash::Wait::TimeoutError, timeout_message
        end
        nil
      end
    end
  end
end
