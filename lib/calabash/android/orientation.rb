module Calabash
  module Android
    module Orientation
      # @!visibility private
      def _set_orientation_landscape
        Device.default.perform_action('set_activity_orientation', 'landscape')
      end

      # @!visibility private
      def _set_orientation_portrait
        Device.default.perform_action('set_activity_orientation', 'portrait')
      end

      # @!visibility private
      def _portrait?
        raise 'not implemented'
      end

      # @!visibility private
      def _landscape?
        raise 'not implemented'
      end
    end
  end
end
