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
  end
end