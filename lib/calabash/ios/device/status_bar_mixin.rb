module Calabash
  module IOS

    # Contains methods for interacting with the status bar.
    module StatusBar

      # Returns the home button position relative to the status bar.
      #
      # @note You should always prefer to use this method over
      #  `device_orientation`.
      #
      # @note This method works even if a status bar is not visible.
      #
      # @return [String] Returns the device orientation as one of
      #  `{'down' | 'up' | 'left' | 'right'}`.
      def status_bar_orientation
        map_route('/orientation', :orientation, :status_bar).first
      end
    end
  end
end
