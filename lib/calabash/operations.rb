module Calabash
  module Operations
    # @!visibility private
    def _start_test_server(opt={})
      abstract_method!
    end

    # @!visibility private
    def _shutdown_test_server(opt={})
      abstract_method!
    end

    # @!visibility private
    def _reinstall(opt={})
      abstract_method!
    end

    # @!visibility private
    def _install(params)
      abstract_method!
    end

    # @!visibility private
    def _uninstall(params)
      abstract_method!
    end
  end
end