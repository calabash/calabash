# @todo: Add not about this class being easily abused
module Calabash
  module Android
    # @!visibility private
    module PhysicalButtons
      def press_button(key)
        Device.default.perform_action('press_key', key)
        true
      end

      def press_back_button
        press_button('KEYCODE_BACK')
      end

      def press_menu_button
        press_button('KEYCODE_MENU')
      end

      def press_down_button
        press_button('KEYCODE_DPAD_DOWN')
      end

      def press_up_button
        press_button('KEYCODE_DPAD_UP')
      end

      def press_left_button
        press_button('KEYCODE_DPAD_LEFT')
      end

      def press_right_button
        press_button('KEYCODE_DPAD_RIGHT')
      end

      def press_enter_button
        press_button('KEYCODE_ENTER')
      end
    end
  end
end
