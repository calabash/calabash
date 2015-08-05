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
        _orientation == 'portrait'
      end

      # @!visibility private
      def _landscape?
        _orientation == 'landscape'
      end

      # @!visibility private
      def _orientation
        Device.default.perform_action('get_activity_orientation')['message']
      end
    end
  end
end
