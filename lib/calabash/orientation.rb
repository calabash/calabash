module Calabash

  # Methods for querying an app's orientation and for rotating the app into
  # different orientations.
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
    #
    # On iOS, the presenting view controller must respond to rotation events.
    # If the presenting view controller does not respond to rotation events,
    # then no rotation will be performed.
    def set_orientation_portrait
      _set_orientation_portrait
    end

    # Set the device orientation to landscape.
    #
    # In landscape orientation, the display of the device has a bigger height
    # than width.
    #
    # On iOS, the presenting view controller must respond to rotation events.
    # If the presenting view controller does not respond to rotation events,
    # then no rotation will be performed.
    def set_orientation_landscape
      _set_orientation_landscape
    end

    # Changes the orientation of the device.
    #
    # If the orientation is currently landscape, it will be set to portrait.
    # If the orientation is currently portrait, it will be set to landscape.
    #
    # On iOS, the presenting view controller must respond to rotation events.
    # If the presenting view controller does not respond to rotation events,
    # then no rotation will be performed.
    def change_orientation
      if portrait?
        set_orientation_landscape
      elsif landscape?
        set_orientation_portrait
      else
        raise 'Could not detect current orientation'
      end
    end

    # @!visibility private
    define_method(:_portrait?) do
      abstract_method!(:_portrait?)
    end

    # @!visibility private
    define_method(:_landscape?) do
      abstract_method!(:_landscape?)
    end

    # @!visibility private
    define_method(:_set_orientation_portrait) do
      abstract_method!(:_set_orientation_portrait)
    end

    # @!visibility private
    define_method(:_set_orientation_landscape) do
      abstract_method!(:_set_orientation_landscape)
    end
  end
end
