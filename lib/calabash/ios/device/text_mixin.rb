module Calabash
  module IOS
    module TextMixin

      def enter_text(text)
        wait_for_keyboard
        uia_type_string(text)
      end

      def _enter_text_in(query, text)
        _tap(query)
        enter_text(text)
      end
    end
  end
end
