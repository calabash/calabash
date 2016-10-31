module Calabash
  module IOS
    # @!visibility private
    module Automator
      # @!visibility private
      class Automator
        include Utility

        # @!visibility private
        def initialize(*args)
          abstract_method!
        end

        # @!visibility private
        def name
          abstract_method!
        end

        # @!visibility private
        def stop
          abstract_method!
        end

        # @!visibility private
        def running?
          abstract_method!
        end

        # @!visibility private
        def client
          abstract_method!
        end

        # @!visibility private
        def touch(options)
          abstract_method!
        end

        # @!visibility private
        def double_tap(options)
          abstract_method!
        end

        # @!visibility private
        def two_finger_tap(options)
          abstract_method!
        end

        # @!visibility private
        def touch_hold(options)
          abstract_method!
        end

        # @!visibility private
        def flick(options)
          abstract_method!
        end

        # @!visibility private
        def pan(options={})
          abstract_method!
        end

        # @!visibility private
        #
        # Callers must validate the options.
        def pan_coordinates(from_point, to_point, options={})
          abstract_method!
        end

        # @!visibility private
        #
        # Callers must validate the options.
        def pinch(in_or_out, options)
          abstract_method!
        end

        # @!visibility private
        def send_app_to_background(seconds)
          abstract_method!
        end

        # @!visibility private
        #
        # It is the caller's responsibility to:
        # 1. expect the keyboard is visible
        # 2. escape the existing text
        def enter_text_with_keyboard(string, options={})
          abstract_method!
        end

        # @!visibility private
        #
        # Respond to keys like 'Delete' or 'Return'.
        def char_for_keyboard_action(action_key)
          abstract_method!
        end

        # @!visibility private
        # It is the caller's responsibility to ensure the keyboard is visible.
        def enter_char_with_keyboard(char)
          abstract_method!
        end

        # @!visibility private
        # It is the caller's responsibility to ensure the keyboard is visible.
        def tap_keyboard_action_key(return_key_type_of_first_responder)
          abstract_method!
        end

        # @!visibility private
        # It is the caller's responsibility to ensure the keyboard is visible.
        def tap_keyboard_delete_key
          abstract_method!
        end

        # @!visibility private
        #
        # Legacy API - can we remove this method?
        #
        # It is the caller's responsibility to ensure the keyboard is visible.
        def fast_enter_text(text)
          abstract_method!
        end

        # @!visibility private
        #
        # Caller is responsible for limiting calls to iPads and waiting for the
        # keyboard to disappear.
        def dismiss_ipad_keyboard
          abstract_method!
        end

        # @!visibility private
        #
        # Caller is responsible for providing a valid direction.
        def rotate(direction, status_bar_orientation)
          abstract_method!
        end

        # @!visibility private
        #
        # Caller is responsible for normalizing and validating the position.
        def rotate_home_button_to(position, status_bar_orientation)
          abstract_method!
        end

        # @! visibility private
        #
        # It is important to remember that the current orientation is the
        # position of the home button:
        #
        # :up => home button on the top => upside_down
        # :bottom => home button on the bottom => portrait
        # :left => home button on the left => landscape_right
        # :right => home button on the right => landscape_left
        #
        # Notice how :left and :right are mapped.
        def self.orientation_key(direction, current_orientation)
          key = nil
          case direction
            when :left then
              if current_orientation == :down
                key = :landscape_left
              elsif current_orientation == :right
                key = :upside_down
              elsif current_orientation == :left
                key = :portrait
              elsif current_orientation == :up
                key = :landscape_right
              end
            when :right then
              if current_orientation == :down
                key = :landscape_right
              elsif current_orientation == :right
                key = :portrait
              elsif current_orientation == :left
                key = :upside_down
              elsif current_orientation == :up
                key = :landscape_left
              end
            else
              raise ArgumentError,
                    "Expected '#{direction}' to be :left or :right"
          end

          key
        end

        # @!visibility private
        def self.orientation_for_key(key)
          DEVICE_ORIENTATION[key]
        end

        # @! visibility private
        #
        # It is important to remember that the current orientation is the
        # position of the home button:
        #
        # :up => home button on the top => upside_down
        # :bottom => home button on the bottom => portrait
        # :left => home button on the left => landscape_right
        # :right => home button on the right => landscape_left
        #
        # Notice how :left and :right are mapped to their logical opposite.
        # @!visibility private
        # @! visibility private
        DEVICE_ORIENTATION = {
            :portrait => 1,
            :upside_down => 2,
            :landscape_left => 3, # Home button on the right
            :landscape_right => 4 # Home button on the left
        }.freeze
      end
    end
  end
end
