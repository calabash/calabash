module Calabash
  module Android
    # @!visibility private
    module Orientation
      # @!visibility private
      define_method(:_set_orientation_landscape) do
        Device.default.perform_action('set_activity_orientation', 'landscape')
      end

      # @!visibility private
      define_method(:_set_orientation_portrait) do
        Device.default.perform_action('set_activity_orientation', 'portrait')
      end

      # @!visibility private
      define_method(:_portrait?) do
        _orientation == 'portrait'
      end

      # @!visibility private
      define_method(:_landscape?) do
        _orientation == 'landscape'
      end

      # @!visibility private
      define_method(:_orientation) do
        Device.default.perform_action('get_activity_orientation')['message']
      end
    end
  end
end
