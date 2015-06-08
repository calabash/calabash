module Calabash
  module Android
    # @!visibility private
    module Text
      def _enter_text_in(query, text)
        tap(query)
        sleep 0.5
        enter_text(text)
      end
    end
  end
end
