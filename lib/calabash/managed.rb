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
    unless respond_to?(:calabash_start_app)
      define_singleton_method(:calabash_start_app) do |application, options, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:calabash_stop_app)
      define_singleton_method(:calabash_stop_app) do |device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:install_app)
      define_singleton_method(:install_app) do |application, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:ensure_app_installed)
      define_singleton_method(:ensure_app_installed) do |application, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:uninstall_app)
      define_singleton_method(:uninstall_app) do |identifier, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:clear_app_data)
      define_singleton_method(:clear_app_data) do |identifier, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:screenshot)
      define_singleton_method(:screenshot) do |name, device|
        invalid_managed_environment!
      end
    end

    # @!visibility private
    unless respond_to?(:port_forward)
      define_singleton_method(:port_forward) do |host_port, device|
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