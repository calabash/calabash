require 'geocoder'

module Calabash

  # An API for setting the location of your app.
  module Location
    # Simulates gps location of the device/simulator.
    # @note Seems UIAutomation is broken here on physical devices on iOS 7.1
    #
    # @example
    #  set_location({latitude: 48.8567, longitude: 2.3508})
    #
    # @example
    #  set_location(coordinates_for_place('The little mermaid, Copenhagen'))
    #
    # @param [Hash] location The location to simulate.
    # @raise [ArgumentError] If location is not a hash and does not contain a
    #  latitude and longitude key.
    def set_location(location)
      unless location.is_a?(Hash)
        raise ArgumentError, "Expected location to be a Hash, not '#{location.class}'"
      end

      unless location[:latitude] || location[:longitude]
        raise ArgumentError, 'You must supply :latitude and :longitude'
      end

      Calabash::Internal.with_default_device {|device| device.set_location(location)}
    end

    # Get the latitude and longitude for a certain place, resolved via Google
    # maps api. This hash can be used in `set_location`.
    #
    # @example
    #  coordinates_for_place('The little mermaid, Copenhagen')
    #  # => {:latitude => 55.6760968, :longitude => 12.5683371}
    #
    # @return [Hash] Latitude and longitude for the given place
    # @raise [RuntimeError] If the place cannot be found
    def coordinates_for_place(place)
      result = Geocoder.search(place)

      if result.empty?
        raise "No result found for '#{place}'"
      end

      {latitude: result.first.latitude,
       longitude: result.first.longitude}
    end
  end
end
