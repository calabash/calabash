module Calabash
  module Orientation
    # Is the device in the portrait orientation?
    #
    # @return [Boolean] Returns true if the device is in the 'up' or 'down'
    #  orientation.
    def portrait?
      _portrait?
    end

    # Is the device in the landscape orientation?
    #
    # @return [Boolean] Returns true if the device is in the 'left' or 'right'
    #  orientation.
    def landscape?
      _landscape?
    end

    # Set the device orientation to portrait.
    #
    # In portrait orientation, the display of the device has a bigger width
    # than height.
    def set_orientation_portrait
      _set_orientation_portrait
    end

    # Set the device orientation to landscape.
    #
    # In landscape orientation, the display of the device has a bigger height
    # than width.
    def set_orientation_landscape
      _set_orientation_landscape
    end

    # @!visibility private
    def _portrait?
      abstract_method!
    end

    # @!visibility private
    def _landscape?
      abstract_method!
    end

    # @!visibility private
    def _set_orientation_portrait
      abstract_method!
    end

    # @!visibility private
    def _set_orientation_landscape
      abstract_method!
    end
  end
end
