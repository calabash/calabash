module Calabash
  module Android
    # Simulates pressing a *physical* button on the device. Use these methods
    # carefully, as only a few devices have hardware key input. They can,
    # however, be very useful for testing behaviour that would be hard to
    # replicate otherwise.
    # @!visibility private
    module PhysicalButtons

      # @!visibility private
      def press_button(key)
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.perform_action('press_key', key)}
        true
      end

      # @!visibility private
      def press_back_button
        press_button('KEYCODE_BACK')
      end

      # @!visibility private
      def press_menu_button
        press_button('KEYCODE_MENU')
      end

      # @!visibility private
      def press_down_button
        press_button('KEYCODE_DPAD_DOWN')
      end

      # @!visibility private
      def press_up_button
        press_button('KEYCODE_DPAD_UP')
      end

      # @!visibility private
      def press_left_button
        press_button('KEYCODE_DPAD_LEFT')
      end

      # @!visibility private
      def press_right_button
        press_button('KEYCODE_DPAD_RIGHT')
      end

      # @!visibility private
      def press_enter_button
        press_button('KEYCODE_ENTER')
      end
    end
  end
end
