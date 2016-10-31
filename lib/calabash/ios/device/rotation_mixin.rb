module Calabash
  module IOS

    # @!visibility private
    module RotationMixin

      # @!visibility private
      def rotate(direction)
        # If we are in the console, we want to be able to rotate without
        # calling start_app.  However, if the Device in the console has not
        # connected with the server, the runtime attributes will not be
        # available. It *might* make sense for the console to do this.
        if defined?(IRB)
          wait_for_server_to_start({:timeout => 1})
        end

        orientation = status_bar_orientation.to_sym

        @automator.rotate(direction, orientation)
      end

      # @!visibility private
      # Caller must pass position one of these positions :down, :left, :right, :up
      def rotate_home_button_to(position)
        valid_positions = [:down, :left, :right, :up]
        unless valid_positions.include?(position)
          raise ArgumentError,
                "Expected '#{position}' to be on of #{valid_positions.join(', ')}"
        end

        # If we are in the console, we want to be able to rotate without
        # calling start_app.  However, if the Device in the console has not
        # connected with the server, the runtime attributes will not be
        # available. It *might* make sense for the console to do this.
        if defined?(IRB)
          wait_for_server_to_start({:timeout => 1})
        end

        orientation = status_bar_orientation.to_sym

        if orientation == position
          return orientation
        end

        @automator.rotate_home_button_to(position, status_bar_orientation)

        orientation.to_s
      end

      private

      ROTATION_CANDIDATES =
            [
                  'rotate_left_home_down',
                  'rotate_left_home_left',
                  'rotate_left_home_right',
                  'rotate_left_home_up',
                  'rotate_right_home_down',
                  'rotate_right_home_left',
                  'rotate_right_home_right',
                  'rotate_right_home_up'
            ]
    end
  end
end
