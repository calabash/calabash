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
      # @todo Decide what to pass as the 'query' parameter.
      def status_bar_orientation
        map_route('/orientation', :orientation, :status_bar).first
      end

      # Is the device in the portrait orientation?
      #
      # @return [Boolean] Returns true if the device is in the 'up' or 'down'
      #  orientation.
      def portrait?
        orientation = status_bar_orientation
        orientation.eql?('up') || orientation.eql?('down')
      end

      # Is the device in the landscape orientation?
      #
      # @return [Boolean] Returns true if the device is in the 'left' or 'right'
      #  orientation.
      def landscape?
        orientation = status_bar_orientation
        orientation.eql?('right') || orientation.eql?('left')
      end
    end
  end
end
