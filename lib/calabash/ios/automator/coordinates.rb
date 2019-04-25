module Calabash
  module IOS
    # @!visibility private
    module Automator
      # @!visibility private
      class Coordinates
        # @!visibility private
        def self.end_point_for_swipe(dir, element)
          case dir
            when :left
              degrees = 0
            when :up
              degrees = 90
            when :right
              degrees = 180
            when :down
              degrees = 270
          end
          radians = degrees * Math::PI / 180.0

          element_width = element["rect"]["width"]
          element_height = element["rect"]["height"]
          x_center = element["rect"]["center_x"]
          y_center = element["rect"]["center_y"]
          radius = ([element_width, element_height].min) * 0.33
          to_x = x_center - (radius * Math.cos(radians))
          to_y = y_center - (radius * Math.sin(radians))
          {:x => to_x, :y => to_y}
        end

        def self.distance(from, to)
          Math.sqrt((from[:x] - to[:x]) ** 2 + (from[:y] - to[:y]) ** 2)
        end
      end
    end
  end
end
