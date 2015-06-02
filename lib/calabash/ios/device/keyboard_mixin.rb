module Calabash
  module IOS

    # @!visibility private
    module KeyboardMixin

      # Returns true if a docked keyboard is visible.
      #
      # A docked keyboard is pinned to the bottom of the view.
      #
      # Keyboards on the iPhone and iPod are docked.
      def docked_keyboard_visible?
        query_result = query_for_keyboard
        return false if query_result.empty?

        return true if device_family_iphone?

        # iPad
        rect = query_result.first['rect']
        orientation = status_bar_orientation.to_sym
        case orientation
          when :left then
            rect['center_x'] == 592 && rect['center_y'] == 512
          when :right then
            rect['center_x'] == 176 && rect['center_y'] == 512
          when :up then
            rect['center_x'] == 384 && rect['center_y'] == 132
          when :down then
            rect['center_x'] == 384 && rect['center_y'] == 892
          else
            false
        end
      end

      # Returns true if an undocked keyboard is visible.
      #
      # A undocked keyboard is floats in the middle of the view.
      #
      # Only iPad keyboards can be undocked.
      def undocked_keyboard_visible?
        return false if device_family_iphone?

        return false if query_for_keyboard.empty?

        not docked_keyboard_visible?
      end

      # Returns true if a split keyboard is visible.
      #
      # A split keyboard is floats in the middle of the view and is split to
      # allow faster thumb typing
      #
      # Only iPad keyboards can be split.
      def split_keyboard_visible?
        return false if device_family_iphone?
        query_for_keyboard_keys.count > 0 && query_for_keyboard.empty?
      end

      # Returns true if there is a visible keyboard.
      def keyboard_visible?
        docked_keyboard_visible? || undocked_keyboard_visible? || split_keyboard_visible?
      end

      # Waits for a keyboard to appear.
      def wait_for_keyboard(timeout)
        message = "Timed out after #{timeout} seconds for the keyboard to appear"
        keyboard_waiter.with_timeout(timeout, message) do
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
      def text_from_keyboard_first_responder
        raise 'There must be a visible keyboard.' unless keyboard_visible?

        text = ''
        ['textField', 'textView'].each do |ui_class|
          text = query_for_text_of_first_responder(ui_class)
          if text.nil?
            text = ''
          else
            break
          end
        end
        text
      end

      private

      # @!visibility private
      # Returns a query string for detecting a keyboard.
      KEYBOARD_QUERY = "view:'UIKBKeyplaneView'"
      KEYBOARD_KEY_QUERY = "view:'UIKBKeyView'"

      def device_family_iphone?
        family = device_family
        family == 'iPhone'
      end

      # Unlike the Calabash Android server, the iOS server does not wait
      # before gestures.  We need to do this in the client for now.
      # @todo Replace with waiting on the iOS Server
      def keyboard_waiter
        @keyboard_waiter ||= lambda do |reference_to_self|
          Class.new do
            include Calabash::Wait
            define_method(:query) do |query, *args|
              reference_to_self.map_route(query, :query, *args)
            end
          end.new
        end.call(self)
      end

      def query_for_keyboard
        keyboard_waiter.query(KEYBOARD_QUERY)
      end

      # When the split keyboard is showing, KEYBOARD_QUERY will return no
      # results.  UIKBKeyView are the individual key views on the keyboard.
      def query_for_keyboard_keys
        keyboard_waiter.query(KEYBOARD_KEY_QUERY)
      end

      def query_for_text_of_first_responder(query)
        result = keyboard_waiter.query("#{query} isFirstResponder:1", :text)
        if result.empty?
          nil
        else
          result.first
        end
      end
    end
  end
end
