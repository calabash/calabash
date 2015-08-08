module Calabash
  module Android
    # Android specific text-related actions.
    module Text
      # Dismisses the current keyboard. This is equivalent to the user
      # pressing the back button if the keyboard is showing. If the keyboard is
      # already hidden/dismissed, nothing is done.
      def dismiss_keyboard
        Device.default.perform_action('hide_soft_keyboard')
        sleep 0.5
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
      def _tap_keyboard_action_key(action_key)
        if action_key.nil?
          Device.default.perform_action('press_user_action_button')
        else
          Device.default.perform_action('press_user_action_button', action_key.to_s)
        end
      end
    end
  end
end
