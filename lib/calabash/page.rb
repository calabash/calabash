module Calabash
  class Page
    private_class_method :new

    def initialize(world)
      @world = world
    end

    def trait
      raise 'Implement your own trait'
    end

    def await(timeout = nil)
      wait_for_view(trait, timeout: timeout)
    end
  end
end
