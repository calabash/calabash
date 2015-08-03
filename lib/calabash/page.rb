module Calabash
  class Page
    # For auto-completion
    include Calabash

    def self.inherited(subclass)
      # Define the page into global scope
      name = subclass.to_s.split('::').last

      unless Object.const_defined?(name.to_sym)
        # We need a unique type for this constant
        clz = Class.new(StubPage)
        Object.const_set(name.to_sym, clz)
      end
    end

    private_class_method :new

    def initialize(world)
      @world = world
    end

    def trait
      raise 'Implement your own trait'
    end

    def await(options={})
      wait_for_view(trait, options)
    end

    # @!visibility private
    class StubPage

    end
  end
end
