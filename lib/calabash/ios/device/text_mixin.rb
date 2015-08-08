module Calabash
  module IOS
    # @!visibility private
    module TextMixin

      # @!visibility private
      def enter_text(text)
        wait_for_keyboard(Calabash::Wait.default_options[:timeout])
        existing_text = text_from_keyboard_first_responder
        options = { existing_text: existing_text }
        uia_type_string(text, options)
      end

      # @!visibility private
      def _enter_text_in(query, text)
        _tap(query)
        enter_text(text)
      end
    end
  end
end
