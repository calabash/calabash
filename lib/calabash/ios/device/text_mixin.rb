module Calabash
  module IOS
    module TextMixin

      def enter_text(text)
        uia_type_string(text)
      end

      def _enter_text_in(query, text)
        _tap(query)
        wait_for_keyboard
        enter_text(text)
      end
    end
  end
end
