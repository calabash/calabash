module Calabash
  module Android
    # @!visibility private
    module Text
      def dismiss_keyboard
        Device.default.perform_action('hide_soft_keyboard')
      end

      # Taps a keyboard action key on the keyboard. Notice that Calabash does
      # not ensure that this particular action key is actually available on the
      # current keyboard.
      #
      # @example
      #  tap_keyboard_action_key(:normal)
      #  tap_keyboard_action_key(:unspecified)
      #  tap_keyboard_action_key(:none)
      #  tap_keyboard_action_key(:go)
      #  tap_keyboard_action_key(:search)
      #  tap_keyboard_action_key(:send)
      #  tap_keyboard_action_key(:next)
      #  tap_keyboard_action_key(:done)
      #  tap_keyboard_action_key(:previous)
      #
      # @see http://developer.android.com/reference/android/view/inputmethod/EditorInfo.html
      #
      # @param [Symbol] action_key The key to press.
      def tap_keyboard_action_key(action_key)
        Device.default.perform_action('press_user_action_button', action_key.to_s)
      end

      # @!visibility private
      def _clear_text
        Device.default.perform_action('clear_text')
      end

      # @!visibility private
      def _clear_text_in(view)
        tap(view)
        sleep 0.5
        clear_text
      end

      # @!visibility private
      def _enter_text(text)
        Device.default.enter_text(text)
      end

      # @!visibility private
      def _enter_text_in(view, text)
        tap(view)
        sleep 0.5
        enter_text(text)
      end

      # @!visibility private
      def _tap_current_keyboard_action_key
        Device.default.perform_action('press_user_action_button')
      end
    end
  end
end
