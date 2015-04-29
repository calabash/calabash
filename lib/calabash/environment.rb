module Calabash
  class Environment
    # Utility method to retrieve an environment variable.
    #
    # @param [String] name of the environment variable
    # @return Value of the environment variable
    def self.variable(name)
      ENV[name]
    end

    # Utility method to set the value of an environment variable.
    #
    # @param [String] name of the environment variable
    # @param Value of the environment variable
    def self.set_variable!(name, value)
      Logger.debug("Setting environment variable '#{name}' to '#{value}'")
      ENV[name] = value
    end

    # Are we running in the Xamarin Test Cloud?
    #
    # @return [Boolean] Returns true if cucumber is running in the test cloud.
    def self.xamarin_test_cloud?
      variable('XAMARIN_TEST_CLOUD') == '1'
    end

    # Is Calabash running in debug mode. True if $CAL_DEBUG is '1'
    DEBUG = variable('CAL_DEBUG') == '1'

    # The path of the default app under test. This value is used if no app is
    # given from the command line. e.g. $ calabash run.
    APP_PATH = variable('CAL_APP')

    # The time in seconds to wait by default before failing in the methods of
    # {Calabash::Wait}. Defaults to 30. Notice that this value is only the
    # **default** for {Calabash::Wait} and that the actual default wait timeout
    # can be changed at any time during the test.
    WAIT_TIMEOUT = (variable('CAL_WAIT_TIMEOUT') &&
        variable('CAL_WAIT_TIMEOUT').to_i) || 30

    # The directory to save screenshots in. The directory can be absolute or
    # relative. Defaults to 'screenshots'.
    SCREENSHOT_DIRECTORY = variable('CAL_SCREENSHOT_DIR') || 'screenshots'

    # The irbrc file to load when starting a console
    IRBRC = (variable('CAL_IRBRC') || (File.exist?('.irbrc') && File.expand_path('.irbrc')) || nil)

    # The Android test server path
    TEST_SERVER_PATH = variable('CAL_TEST_SERVER')
  end
end
