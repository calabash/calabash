module Calabash
  module Android
    module Text
      def dismiss_keyboard
        Device.default.perform_action('hide_soft_keyboard')
      end

      # @!visibility private
      def _clear_text
        Device.default.perform_action('clear_text')
      end

      def _clear_text_in(view)
        tap(view)
        sleep 0.5
        clear_text
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
