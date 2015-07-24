module Calabash
  module IOS

    # On iOS, the presenting view controller must respond to rotation events.
    # If the presenting view controller does not respond to rotation events,
    # then no rotation will be performed.
    module Orientation

      # Returns the home button position relative to the status bar.
      #
      # @note This method works even if a status bar is not visible.
      #
      # @return [String] Returns the device orientation as one of
      #  `{'down' | 'up' | 'left' | 'right'}`.
      def status_bar_orientation
        Device.default.status_bar_orientation
      end

      # On iOS, the presenting view controller must respond to rotation events.
      # If the presenting view controller does not respond to rotation events,
      # then no rotation will be performed.

      # Rotates the device in the direction indicated by `direction`.
      #
      # @example
      #  > rotate('left')
      #  > rotate('right')
      #
      # @note
      #   The presenting view controller must respond to rotation events.
      #   If the presenting view controller does not respond to rotation events,
      #   then no rotation will be performed.
      #
      # @param [String] direction The direction in which to rotate.
      #  Valid arguments are :left and :right
      #
      # @raise [ArgumentError] If an invalid direction is given.
      # @return [String] The orientation of the status bar after the rotation.
      def rotate(direction)
        unless direction == 'left' || direction == 'right'
          raise ArgumentError, "Expected '#{direction}' to be 'left' or 'right'"
        end

        result = Device.default.rotate(direction.to_sym)
        wait_for_animations
        result
      end

      # @!visibility private
      def _set_orientation_landscape
        raise 'ni'
      end

      # @!visibility private
      def _set_orientation_portrait
        raise 'ni'
      end

      # @!visibility private
      def _portrait?
        orientation = status_bar_orientation
        orientation.eql?('up') || orientation.eql?('down')
      end

      # @!visibility private
      def _landscape?
        orientation = status_bar_orientation
        orientation.eql?('right') || orientation.eql?('left')
      end
    end
  end
end
