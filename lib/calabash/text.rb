module Calabash

  # A public API for entering text.
  module Text
    # Enter `text` into the currently focused view.
    #
    # @param [String] text The text to type.
    # @raise [RuntimeError] if the text cannot be typed.
    def enter_text(text)
      _enter_text(text.to_s)
    end

    # Enter `text` into `query`.
    # @see Calabash::Text#enter_text
    #
    # @param [String] text The text to type.
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #  to enter text into.
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
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #  to clear text in.
    def clear_text_in(query)
      _clear_text_in(query)
    end

    # Taps the keyboard action key. On iOS there is only one action key, which
    # is the blue coloured key on the standard keyboard. On Android, there can
    # be multiple actions keys available depending on the keyboard, but one key
    # is often replacing the enter key, becoming the default action key. The
    # view in focus on Android asks to keyboard to show one action key, but the
    # keyboard might not adhere to this.
    #
    # On iOS some examples include:
    #  * Return
    #  * Next
    #  * Go
    #  * Join
    #  * Search
    #
    # On Android some examples include:
    #  * Search
    #  * Next
    #  * Previous
    #
    # See http://developer.android.com/reference/android/view/inputmethod/EditorInfo.html
    #
    # @example
    #  tap_keyboard_action_key(:search)
    #  tap_keyboard_action_key(:send)
    #  tap_keyboard_action_key(:next)
    #  tap_keyboard_action_key(:previous)
    #
    # Notice that, for Android, Calabash does not ensure that this particular action key is
    # actually available on the current keyboard.
    #
    # Not all keyboards have an action key. For example, on iOS, numeric keyboards
    # do not have an action key. On Android, if no action key is set for the
    # view, the enter key is pressed instead.
    #
    # @param [Symbol] action_key The action key to press. This is only
    #  used for Android.
    # @raise [ArgumentError] If action_key if set for iOS.
    def tap_keyboard_action_key(action_key = nil)
      _tap_keyboard_action_key(action_key)
      true
    end

    # Escapes single quotes in `string`.
    #
    # @example
    #   escape_single_quotes("Let's get this done.")
    #   => "Let\\'s get this done."
    #
    # @example
    #  query("* text:'#{escape_single_quotes("Let's go")}'")
    #  # Equivalent to
    #  query("* text:'Let\\'s go'")
    #
    # @param [String] string The string to escape.
    # @return [String] A string with its single quotes properly escaped.
    def escape_single_quotes(string)
      Text.escape_single_quotes(string)
    end

    # Returns true if there is a visible keyboard.
    # On Android, if a physical keyboard is connected, this method will always
    # return true.
    #
    # @return [Boolean] Returns true if there is a visible keyboard.
    def keyboard_visible?
      _keyboard_visible?
    end

    # Waits for a keyboard to appear.
    #
    # @see Calabash::Wait.default_options
    #
    # @param [Number] timeout How long to wait for the keyboard.
    # @raise [Calabash::Wait::TimeoutError] Raises error if no keyboard
    #  appears.
    def wait_for_keyboard(timeout=nil)
      keyboard_timeout = keyboard_wait_timeout(timeout)
      message = "Timed out after #{keyboard_timeout} seconds waiting for the keyboard to appear"
      wait_for(message, timeout: keyboard_timeout) do
        keyboard_visible?
      end
    end

    # Waits for the keyboard to disappear.
    #
    # @see Calabash::Wait.default_options
    #
    # @param [Number] timeout How log to wait for the keyboard to disappear.
    # @raise [Calabash::Wait::TimeoutError] Raises error if any keyboard is
    #  visible after the `timeout`.
    def wait_for_no_keyboard(timeout=nil)
      keyboard_timeout = keyboard_wait_timeout(timeout)
      message = "Timed out after #{keyboard_timeout} seconds waiting for the keyboard to disappear"
      wait_for(message, timeout: keyboard_timeout) do
        !keyboard_visible?
      end
    end

    # @!visibility private
    def _enter_text(text)
      abstract_method!
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
    def _tap_keyboard_action_key(action_key)
      abstract_method!
    end

    # @!visibility private
    def _keyboard_visible?
      abstract_method!
    end

    # @!visibility private
    def self.escape_single_quotes(string)
      string.gsub("'", "\\\\'")
    end

    # @!visibility private
    def keyboard_wait_timeout(timeout)
      if timeout.nil?
        Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT
      else
        timeout
      end
    end
  end
end
