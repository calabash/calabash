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
      abstract_method!
    end

    # @!visibility private
    def _install(params)
      Device.default.install(params)
    end

    # @!visibility private
    def _uninstall(params)
      Device.default.uninstall(params)
    end
  end
end
