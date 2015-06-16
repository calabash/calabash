module Calabash
  module IOS
    module Orientation
      # Returns the home button position relative to the status bar.
      #
      # @note This method works even if a status bar is not visible.
      #
      # @return [String] Returns the device orientation as one of
      #  `{'down' | 'up' | 'left' | 'right'}`.
      def status_bar_orientation
        Device.default.status_bar_orientation
      end

      # @!visibility private
      def _portrait?
        orientation = status_bar_orientation
        orientation.eql?('up') || orientation.eql?('down')
      end

      # @!visibility private
      def _landscape?
        orientation = status_bar_orientation
        orientation.eql?('right') || orientation.eql?('left')
      end
    end
  end
end
