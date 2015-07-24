module Calabash
  module Android
    module Interactions
      def go_back
        dismiss_keyboard
        press_back_button
      end

      def go_home
        Device.default.go_home
      end
    end
  end
end
