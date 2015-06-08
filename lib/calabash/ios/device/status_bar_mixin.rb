module Calabash
  module IOS
    # @!visibility private
    module StatusBarMixin

      # Returns the home button position relative to the status bar.
      #
      # @note This method works even if a status bar is not visible.
      #
      # @return [String] Returns the device orientation as one of
      #  `{'down' | 'up' | 'left' | 'right'}`.
      def status_bar_orientation
        map_route(nil, :orientation, :status_bar).first
      end
    end
  end
end
