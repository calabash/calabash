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
      ENV[name] = value
    end

    # The path for the default application being tested
    #
    # @return Path of default application
    def self.default_application_path
      Environment.variable('CALABASH_APP')
    end
  end
end