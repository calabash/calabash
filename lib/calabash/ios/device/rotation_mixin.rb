module Calabash
  module IOS

    # @!visibility private
    module RotationMixin

      def rotate(direction)
        # If we are in the console, we want to be able to rotate without
        # calling start_app.  However, if the Device in the console has not
        # connected with the server, the runtime attributes will not be
        # available. It *might* make sense for the console to do this.
        if defined?(IRB)
          wait_for_server_to_start({:timeout => 1})
        end

        family = device_family

        current_orientation = status_bar_orientation.to_sym
        recording_name = nil
        case direction
          when :left
            if current_orientation == :down
              recording_name = 'left_home_down'
            elsif current_orientation == :right
              recording_name = 'left_home_right'
            elsif current_orientation == :left
              recording_name = 'left_home_left'
            elsif current_orientation == :up
              recording_name = 'left_home_up'
            end
          when :right
            if current_orientation == :down
              recording_name = 'right_home_down'
            elsif current_orientation == :left
              recording_name = 'right_home_left'
            elsif current_orientation == :right
              recording_name = 'right_home_right'
            elsif current_orientation == :up
              recording_name = 'right_home_up'
            end
          else
            # Caller should have guarded us against this case.
            raise ArgumentError, "Expected '#{direction}' to be :left or :right"
        end

        if family == 'iPad'
          form_factor = 'ipad'
        else
          form_factor = 'iphone'
        end

        if recording_name.nil?
          raise "Could not rotate device in direction '#{direction}' " \
                "with orientation '#{current_orientation}'"
        end

        recording_name = "rotate_#{recording_name}"
        playback_route(recording_name, form_factor)
      end

      # @!visibility private
      # Caller must pass position one of these positions down, left, right, up
      def rotate_home_button_to(position)

        valid_positions = ['down', 'left', 'right', 'up']
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

        orientation = status_bar_orientation

        if orientation == position
          return orientation
        end

        family = device_family

        if family == 'iPad'
          form_factor = 'ipad'
        else
          form_factor = 'iphone'
        end

        ROTATION_CANDIDATES.each do |recording_name|
          playback_route(recording_name, form_factor)

          # Wait for rotation animation.
          timeout = 1.0
          condition_route('NONE_ANIMATING', timeout, '*')

          orientation = status_bar_orientation
          if orientation == position
            return orientation
          end
        end

        orientation
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
