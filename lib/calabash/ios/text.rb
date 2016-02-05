module Calabash
  module IOS
    # Methods for entering text and interacting with iOS keyboards.
    module Text
      # @!visibility private
      def _enter_text(text)
        wait_for_keyboard
        existing_text = text_from_keyboard_first_responder
        options = { existing_text: existing_text }
        Device.default.uia_type_string(text, options)
      end

      # @!visibility private
      def _enter_text_in(view, text)
        tap(view)
        enter_text(text)
      end

      # @!visibility private
      def _clear_text
        unless view_exists?("* isFirstResponder:1")
          raise 'Cannot clear text. No view has focus'
        end

        clear_text_in("* isFirstResponder:1")
      end

      # @!visibility private
      def _clear_text_in(view)
        unless keyboard_visible?
          tap(view)
          wait_for_keyboard
        end

        unless wait_for_view(view)['text'].empty?
          tap(view)
          tap("UICalloutBarButton marked:'Select All'")
          tap_keyboard_delete_key
        end

        true
      end

      # Returns true if a docked keyboard is visible.
      #
      # A docked keyboard is pinned to the bottom of the view.
      #
      # Keyboards on the iPhone and iPod are docked.
      #
      # @return [Boolean] Returns true if a keyboard is visible and docked.
      def docked_keyboard_visible?
        Device.default.docked_keyboard_visible?
      end

      # Returns true if an undocked keyboard is visible.
      #
      # A undocked keyboard is floats in the middle of the view.
      #
      # @return [Boolean] Returns false if the device is not an iPad; all
      # keyboards on the iPhone and iPod are docked.
      def undocked_keyboard_visible?
        Device.default.undocked_keyboard_visible?
      end

      # Returns true if a split keyboard is visible.
      #
      # A split keyboard is floats in the middle of the view and is split to
      # allow faster thumb typing
      #
      # @return [Boolean] Returns false if the device is not an iPad; all
      # keyboards on the Phone and iPod are docked and not split.
      def split_keyboard_visible?
        Device.default.split_keyboard_visible?
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

      # Touches the keyboard action key.
      #
      # The action key depends on the keyboard.  Some examples include:
      #
      # * Return
      # * Next
      # * Go
      # * Join
      # * Search
      #
      # Not all keyboards have an action key.  For example, numeric keyboards
      #  do not have an action key.
      #
      # @raise [RuntimeError] If the text cannot be typed.
      # @todo Refactor uia_route to a public API call
      # @todo Move this documentation to the public method
      # @!visibility private
      def _tap_keyboard_action_key(action_key)
        unless action_key.nil?
          raise ArgumentError,
                "An iOS keyboard does not have multiple action keys"
        end

        char_sequence = ESCAPED_KEYBOARD_CHARACTERS[:action]
        Device.default.uia_route("uia.keyboard().typeString('#{char_sequence}')")
      end

      # @!visibility private
      def _keyboard_visible?
        docked_keyboard_visible? || undocked_keyboard_visible? || split_keyboard_visible?
      end

      # Touches the keyboard delete key.
      #
      # The 'delete' key difficult to find and touch because its behavior
      # changes depending on the iOS version and keyboard type.  Consider the
      # following:
      #
      # On iOS 6, the 'delete' char code is _not_ \b.
      # On iOS 7: The Delete char code is \b on non-numeric keyboards.
      #           On numeric keyboards, the delete key is a button on the
      #           the keyboard.
      #
      # By default, Calabash uses a raw UIAutomaton JavaScript call to tap the
      # element named 'Delete'.  This works well in English localizations for
      # most keyboards.  If you find that it does not work, use the options
      # pass either an translation of 'Delete' for your localization or use the
      # default the escaped keyboard character.
      #
      # @example
      #   # Uses UIAutomation to tap the 'Delete' key or button.
      #   tap_keyboard_delete_key
      #
      #   # Types the \b key.
      #   tap_keyboard_delete_key({:use_escaped_char => true})
      #
      #   # Types the \d key.
      #   tap_keyboard_delete_key({:use_escaped_char => '\d'})
      #
      #   # Uses UIAutomation to tap the 'Slet' key or button.
      #   tap_keyboard_delete_key({:delete_key_label => 'Slet'})
      #
      #   # Don't specify both options!  If :use_escape_sequence is truthy,
      #   # Calabash will ignore the :delete_key_label and try to use an
      #   # escaped character sequence.
      #   tap_keyboard_delete_key({:use_escaped_char => true,
      #                            :delete_key_label => 'Slet'})
      #
      # @param [Hash] options Alternative ways to tap the delete key.
      # @option options [Boolean, String] :use_escaped_char (false) If true,
      #  delete by typing the \b character.  If this value is truthy, but not
      #  'true', they it is expected to be an alternative escaped character.
      # @option options [String] :delete_key_label ('Delete') An alternative
      #  localization of 'Delete'.
      # @todo Need translations of 'Delete' key.
      def tap_keyboard_delete_key(options = {})
        default_options =
            {
                use_escaped_char: false,
                delete_key_label: 'Delete'
            }
        merged_options = default_options.merge(options)

        use_escape_sequence = merged_options[:use_escaped_char]
        if use_escape_sequence
          if use_escape_sequence.to_s == 'true'
            # Use the default \b
            char_sequence = ESCAPED_KEYBOARD_CHARACTERS[:delete]
          else
            char_sequence = use_escape_sequence
          end
          return Device.default.uia_route("uia.keyboard().typeString('#{char_sequence}')")
        end

        delete_key_label = merged_options[:delete_key_label]
        uia = "uia.keyboard().elements().firstWithName('#{delete_key_label}').tap()"
        Device.default.uia_route(uia)
      end

      # Returns the the text in the first responder.
      #
      # The first responder will be the UITextField or UITextView instance
      # that is associated with the visible keyboard.
      #
      # Returns empty string if no textField or textView elements are found to be
      # the first responder.  Otherwise, it will return the text in the
      # UITextField or UITextField that is associated with the keyboard.
      #
      # @raise [RuntimeError] If there is no visible keyboard.
      def text_from_keyboard_first_responder
        Device.default.text_from_keyboard_first_responder
      end

      private

      # @!visibility private
      # noinspection RubyStringKeysInHashInspection
      ESCAPED_KEYBOARD_CHARACTERS =
          {
              :action => '\n',

              # This works for some combinations of keyboard types and
              # iOS version.  The current solution is use a raw UIA call
              # to find the 'Delete' key, which may not work in some
              # situations, for example in non-English environments.  The
              # tap_keyboard_delete_key allows an option to us this escape
              # sequence.
              :delete => '\b',

              # These are not supported yet and I am pretty sure that they
              # cannot be touched by passing an escaped character and instead
              # the must be found using UIAutomation calls.  -jmoody
              #'Dictation' => nil,
              #'Shift' => nil,
              #'International' => nil,
              #'More' => nil,
          }

      def keyboard_wait_timeout(timeout)
        if timeout.nil?
          Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT
        else
          timeout
        end
      end
    end
  end
end
