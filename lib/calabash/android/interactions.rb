module Calabash
  module Android
    module Interactions
      def go_back
        dismiss_keyboard
        press_back_button
      end
    end
  end
end
