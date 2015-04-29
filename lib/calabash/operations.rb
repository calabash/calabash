module Calabash
  module Operations
    # @!visibility private
    def _calabash_start_app(opt={})
      abstract_method!
    end

    # @!visibility private
    def _calabash_stop_app(opt={})
      abstract_method!
    end

    # @!visibility private
    def _reinstall(opt={})
      uninstall(Application.default)
      install(Application.default)
    end

    # @!visibility private
    def _install(path_or_application)
      Device.default.install(path_or_application)
    end

    # @!visibility private
    def _uninstall(path_or_application)
      Device.default.uninstall(path_or_application)
    end

    # @!visibility private
    def _clear_app(path_or_application)
      Device.default.clear_app(path_or_application)
    end
  end
end
