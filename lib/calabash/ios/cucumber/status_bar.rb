module Calabash
  module IOS
    module Cucumber
      # Returns the home button position relative to the status bar.
      #
      # @note This method works even if a status bar is not visible.
      #
      # @return [String] Returns the device orientation as one of
      #  `{'down' | 'up' | 'left' | 'right'}`.
      def status_bar_orientation
        Device.default.status_bar_orientation
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
