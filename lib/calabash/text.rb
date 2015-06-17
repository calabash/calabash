module Calabash

  # A public API for entering text.
  module Text
    # Enter `text` into the currently focused view.
    #
    # @param [String] text The text to type.
    # @raise [RuntimeError] if the text cannot be typed.
    def enter_text(text)
      Device.default.enter_text(text)
    end

    # Enter `text` into `query`.
    # @see Calabash::Text#enter_text
    #
    # @param [String] text The text to type.
    # @param query A query describing the view to enter text into.
    def enter_text_in(query, text)
      _enter_text_in(query, text)
    end

    # Clears the text of the currently focused view.
    def clear_text
      _clear_text
    end

    # Clears the text `view`
    # @see Calabash::Text#clear_text
    #
    # @param query A query describing the view to clear text in.
    def clear_text_in(view)
      _clear_text_in(view)
    end

    # @todo add docs
    def tap_keyboard_action_key
      _tap_keyboard_action_key
    end

    # Escapes single quotes in `string`.
    #
    # @example
    #   > escape_quotes("Let's get this done.")
    #   => "Let\\'s get this done."
    # @param [String] string The string to escape.
    # @return [String] A string with its single quotes properly escaped.
    def escape_single_quotes(string)
      Text.escape_single_quotes(string)
    end

    # @!visibility private
    def _enter_text_in(view, text)
      abstract_method!
    end

    # @!visibility private
    def _clear_text
      abstract_method!
    end

    # @!visibility private
    def _clear_text_in(view)
      abstract_method!
    end

    # @!visibility private
    def _tap_keyboard_action_key
      abstract_method!
    end

    # @!visibility private
    def self.escape_single_quotes(string)
      string.gsub("'", "\\\\'")
    end
  end
end
