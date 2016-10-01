module Calabash

  # @!visibility private
  class AbstractMethodError < StandardError

  end

  # Utility methods for testing.
  module Utility
    # @!visibility private
    def abstract_method!(method_name=nil)
      method_name ||= if Kernel.method_defined?(:caller_locations)
                      caller_locations.first.label
                    else
                      caller.first[/\`(.*)\'/, 1]
                    end

      raise AbstractMethodError.new("Abstract method '#{method_name.to_s}'")
    end

    # @!visibility private
    class RetryError < RuntimeError; end

    # A convenience method for creating a percentage hash that that can be
    # passed to gestures.
    #
    # @example
    #  # These are equivalent.
    #  pan("*", percent(20, 50), percent(20, 100))
    #  pan("*", {x: 20, y: 50}, {x: 20, y: 100})
    #
    # @param [Number] x The value of the x percent.
    # @param [Number] y The value of the y percent.
    # @return [Hash] Representing the given values.
    def percent(x, y)
      {x: x, y: y}
    end

    alias_method :pct, :percent

    # A convenience method for creating a coordinate hash that that can be
    # passed to the tap_coordinate gesture.
    #
    # @example
    #  # These are equivalent.
    #  tap_coordinate(coordinate(20, 50)
    #  tap_coordinate({x: 20, y: 50})
    #
    # @param [Number] x The value of the x.
    # @param [Number] y The value of the y.
    # @return [Hash] Representing the given values.
    def coordinate(x, y)
      {x: x, y: y}
    end

    alias_method :coord, :coordinate

    # @!visibility private
    def self.used_bundler?
      defined?(Bundler) && !ENV['BUNDLE_BIN_PATH'].nil?
    end

    # @!visibility private
    def self.bundle_exec_prepend
      if used_bundler?
        'bundle exec '
      else
        ''
      end
    end
  end
end
