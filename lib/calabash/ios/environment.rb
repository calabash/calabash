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
    end
  end
end

