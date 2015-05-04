module Calabash
  module Operations
    # @!visibility private
    def _calabash_start_app(application, options={})
      test_options = options.dup

      Calabash::Device.default.calabash_start_app(application, test_options)
    end

    # @!visibility private
    def _calabash_stop_app
      Calabash::Device.default.calabash_stop_app
    end

    # @!visibility private
    def _install_app(path_or_application)
      Device.default.install_app(path_or_application)
    end

    # @!visibility private
    def _ensure_app_installed(path_or_application)
      Device.default.ensure_app_installed(path_or_application)
    end

    # @!visibility private
    def _uninstall_app(path_or_application)
      Device.default.uninstall_app(path_or_application)
    end

    # @!visibility private
    def _clear_app(path_or_application)
      Device.default.clear_app(path_or_application)
    end
  end
end
