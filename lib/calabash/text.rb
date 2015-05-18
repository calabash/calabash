module Calabash
  module Text
    # Enter `text` into the currently focused view.
    #
    # @param [String] text The text to type.
    # @raise [RuntimeError] if the text cannot be typed.
    def enter_text(text)
      Device.default.enter_text(text)
    end
  end
end
