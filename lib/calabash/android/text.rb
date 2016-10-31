module Calabash
  module Android
    # Android specific text-related actions.
    module Text
      # Dismisses the current keyboard. This is equivalent to the user
      # pressing the back button if the keyboard is showing. If the keyboard is
      # already hidden/dismissed, nothing is done.
      def dismiss_keyboard
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.perform_action('hide_soft_keyboard')}
        sleep 0.5
      end

      # @!visibility private
      define_method(:_clear_text) do
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.perform_action('clear_text')}
      end

      # @!visibility private
      define_method(:_clear_text_in) do |view|
        tap(view)
        sleep 0.5
        clear_text
      end

      # @!visibility private
      define_method(:_enter_text) do |text|
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.enter_text(text)}
      end

      # @!visibility private
      define_method(:_enter_text_in) do |view, text|
        tap(view)
        sleep 0.5
        enter_text(text)
      end

      # @!visibility private
      define_method(:_tap_keyboard_action_key) do |action_key|
        if action_key.nil?
          Calabash::Internal.with_default_device(required_os: :android) {|device| device.perform_action('press_user_action_button')}
        else
          Calabash::Internal.with_default_device(required_os: :android) {|device| device.perform_action('press_user_action_button', action_key.to_s)}
        end
      end

      # @!visibility private
      define_method(:_keyboard_visible?) do
        Calabash::Internal.with_default_device(required_os: :android) {|device| device.keyboard_visible?}
      end
    end
  end
end
