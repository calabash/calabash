module Calabash
  # @!visibility private
  module Patch

    # @!visibility private
    module Array
      def to_pct
        if length != 2
          raise RangeError, "Cannot convert #{self} to {:x, :y} hash"
        end

        {x: self.[](0), y: self.[](1)}
      end
    end
  end
end
