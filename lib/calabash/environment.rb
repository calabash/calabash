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
  end
end