module Calabash
  module Android
    # @!visibility private
    module Text
      def _enter_text_in(query, text)
        tap(query)
        sleep 0.5
        enter_text(text)
      end

      def _tap_keyboard_action_key
        Device.default.perform_action('press_user_action_button')
      end
    end
  end
end
