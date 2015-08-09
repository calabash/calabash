module Calabash
  module IOS

    # Constants that describe the iOS test environment.
    class Environment < Calabash::Environment

      # A URI that points to the embedded Calabash server in the app under test.
      #
      # The default value is 'http://localhost:37265'.
      #
      # You can control the value of this variable by setting the `CAL_ENDPOINT`
      # variable.
      #
      # @todo Maybe rename this to CAL_SERVER_URL or CAL_SERVER?
      DEVICE_ENDPOINT = URI.parse((variable('CAL_ENDPOINT') || 'http://localhost:37265'))

      # The strategy use when interacting with UIAutomation.  Calabash iOS
      # supports 3 strategies:
      #
      # 1. preferences: Fast, but only works on simulators and on devices < 8.0.
      # 2. shared:  Fast, but has limited functionality.  For example, you
      #             can't send apps to the background.
      # 3. host: Slow, but the only option for devices >= 8.0.
      #
      # Calabash and run-loop will work together to figure out the fastest,
      # most feature complete strategy to use at runtime.
      #
      # This is an advanced feature.  Don't set this variable unless you know
      # what you are doing.
      UIA_STRATEGY = lambda do
        strategy = variable('CAL_UIA_STRATEGY')
        if strategy
          strategy.to_sym
        else
          nil
        end
      end.call
    end
  end
end

