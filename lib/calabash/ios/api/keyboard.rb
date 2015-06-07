module Calabash
  module IOS
    module API

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

      # Returns true if there is a visible keyboard.
      #
      # @return [Boolean] Returns true if there is a visible keyboard.
      def keyboard_visible?
        docked_keyboard_visible? || undocked_keyboard_visible? || split_keyboard_visible?
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

      def keyboard_wait_timeout(timeout)
        if timeout.nil?
          Calabash::Wait.default_options[:timeout]
        else
          timeout
        end
      end
    end
  end
end
