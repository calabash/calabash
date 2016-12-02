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
        Calabash::Internal.with_current_target(required_os: :ios) {|target| target.status_bar_orientation}
      end

      # Rotate the device left - clockwise relative to the home button.
      #
      # @note
      #   The presenting view controller must respond to rotation events.
      #   If the presenting view controller does not respond to rotation events,
      #   then no rotation will be performed.
      #
      # @return [String] The position of the home button relative to the status
      #  bar after the rotation. Can be one of 'down', 'left', 'right', 'up'.
      def rotate_device_left
        Calabash::Internal.with_current_target(required_os: :ios) {|target| target.rotate(:left)}
        status_bar_orientation
      end

      # Rotate the device right - counterclockwise relative to the home button.
      #
      # @note
      #   The presenting view controller must respond to rotation events.
      #   If the presenting view controller does not respond to rotation events,
      #   then no rotation will be performed.
      #
      # @return [String] The position of the home button relative to the status
      #  bar after the rotation. Can be one of 'down', 'left', 'right', 'up'.
      def rotate_device_right
        Calabash::Internal.with_current_target(required_os: :ios) {|target| target.rotate(:right)}
        status_bar_orientation
      end

      # Rotates the home button to a position relative to the status bar.
      #
      # @example portrait
      #  rotate_home_button_to 'down'
      #  rotate_home_button_to 'bottom'
      #
      # @example upside down
      #  rotate_home_button_to 'top'
      #  rotate_home_button_to 'up'
      #
      # @example landscape with left home button AKA: _right_ landscape
      #  rotate_home_button_to 'left'
      #
      # @example landscape with right home button AKA: _left_ landscape
      #  rotate_home_button_to 'right'
      #
      # @note Refer to Apple's documentation for clarification about left vs.
      #  right landscape orientations.
      #
      # @note
      #   The presenting view controller must respond to rotation events.
      #   If the presenting view controller does not respond to rotation events,
      #   then no rotation will be performed.
      #
      # @raise [ArgumentError] If an invalid position is given.
      #
      # @return [String] The position of the home button relative to the status
      #  bar after the rotation. Can be one of 'down', 'left', 'right', 'up'.
      def rotate_home_button_to(position)
        valid_positions = [:down, :bottom, :top, :up, :left, :right]
        unless valid_positions.include?(position.to_sym)
          raise ArgumentError,
                "Expected '#{position}' to be one of #{valid_positions.join(', ')}"
        end

        canonical_position = position.to_sym
        canonical_position = :down if position.to_sym == :bottom
        canonical_position = :up if position.to_sym == :top

        Calabash::Internal.with_current_target(required_os: :ios) {|target| target.rotate_home_button_to(canonical_position)}
      end

      # @!visibility private
      define_method(:_set_orientation_landscape) do
        orientation = status_bar_orientation
        return orientation if landscape?

        rotate_home_button_to 'right'
      end

      # @!visibility private
      define_method(:_set_orientation_portrait) do
        orientation = status_bar_orientation
        return orientation if portrait?

        rotate_home_button_to 'down'
      end

      # @!visibility private
      define_method(:_portrait?) do
        orientation = status_bar_orientation
        orientation.eql?('up') || orientation.eql?('down')
      end

      # @!visibility private
      define_method(:_landscape?) do
        orientation = status_bar_orientation
        orientation.eql?('right') || orientation.eql?('left')
      end
    end
  end
end
