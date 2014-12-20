# These methods define functionality when running in a managed environment (e.g. Xamarin Test Cloud)
# Do not modify any of these methods
module Calabash
  class InvalidManagedEnvironment < ScriptError

  end

  class Managed
    # Are we running in a managed environment?
    #
    # @return [Boolean] Returns true if Calabash is running in a manged environment.
    def self.managed?
      Environment.xamarin_test_cloud?
    end

    # @!visibility private
    def self.invalid_managed_environment!
      raise InvalidManagedEnvironment.new('Invalid managed environment. Standard users should never setup their own managed environment')
    end

    # @!visibility private
    def self.install(params)
      invalid_managed_environment!
    end

    # @!visibility private
    def self.uninstall(params)
      invalid_managed_environment!
    end
  end
end