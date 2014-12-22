# These methods define functionality when running in a managed environment (e.g. Xamarin Test Cloud)
# Never modify any of these methods! If you need to run in a managed environment, patch this class.
#
# Notice that the Managed class will not redefine the methods if they already exist. This removes
# possible timing issues when loading Calabash and loading the patching files.
module Calabash
  class InvalidManagedEnvironment < ScriptError

  end

  class Managed
    # Are we running in a managed environment?
    #
    # Never modify this method! Modify _managed? instead
    #
    # @return [Boolean] Returns true if Calabash is running in a manged environment.
    def self.managed?
      _managed?
    end

    # @!visibility private
    # Never modify this method!
    def self.invalid_managed_environment!
      raise InvalidManagedEnvironment.new('Invalid managed environment. Standard users should never setup their own managed environment')
    end

    # @!visibility private
    unless respond_to?(:install)
      define_singleton_method(:install) do |params|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:uninstall)
      define_singleton_method(:uninstall) do |params|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:_managed?)
      define_singleton_method(:_managed?) do
        false
      end
    end
  end
end