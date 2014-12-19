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

    # The path for the default application being tested
    #
    # @return Path of default application
    def self.default_application_path
      Environment.variable('CALABASH_APP')
    end

    # Are we running in the Xamarin Test Cloud?
    #
    # @return [Boolean] Returns true if cucumber is running in the test cloud.
    def self.xamarin_test_cloud?
      variable('XAMARIN_TEST_CLOUD') == '1'
    end

    # Are we running in a managed environment?
    #
    # @return [Boolean] Returns true if Calabash is running in a manged environment.
    def self.managed?
      xamarin_test_cloud?
    end
  end
end