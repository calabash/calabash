module Calabash
  module Android
    module Text
      def hide_keyboard
        Device.default.perform_action('hide_soft_keyboard')
      end

      def clear_text
        Device.default.perform_action('clear_text')
      end

      def clear_text_in(query)
        tap(query)
        sleep 0.5
        clear_text
      end

      # @!visibility private
      def _enter_text_in(query, text)
        tap(query)
        sleep 0.5
        enter_text(text)
      end

      # @!visibility private
      def _tap_keyboard_action_key
        Device.default.perform_action('press_user_action_button')
      end
    end
  end
end
