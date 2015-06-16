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

    # @!visibility private
    def _portrait?
      abstract_method!
    end

    # @!visibility private
    def _landscape?
      abstract_method!
    end
  end
end
