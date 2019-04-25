require 'geocoder'

module Calabash

  # An API for setting the location of your app.
  module Location
    # Simulates gps location of the device/simulator.
    #
    # @example
    #  cal.set_location(latitude: 48.8567, longitude: 2.3508)
    #
    # @example
    #  cal.set_location(coordinates_for_place('The little mermaid, Copenhagen'))
    #
    # @param [Number] latitude The latitude of the location to simulate.
    # @param [Number] longitude The longitude of the location to simulate.
    # @raise [ArgumentError] If not given a latitude or longitude key.
    def set_location(latitude: nil, longitude: nil)
      unless latitude
        raise ArgumentError, "Expected latitude to be a number, not '#{latitude.class}'"
      end

      unless longitude
        raise ArgumentError, "Expected longitude to be a number, not '#{longitude.class}'"
      end

      Calabash::Internal.with_current_target {|target| target.set_location(latitude: latitude, longitude: longitude)}
    end

    # Get the latitude and longitude for a certain place, resolved via Google
    # maps api. This hash can be used in `set_location`.
    #
    # @example
    #  cal.coordinates_for_place('The little mermaid, Copenhagen')
    #  # => {:latitude => 55.6760968, :longitude => 12.5683371}
    #
    # @return [Hash] Latitude and longitude for the given place
    # @raise [RuntimeError] If the place cannot be found
    def coordinates_for_place(place_name)
      result = Geocoder.search(place_name)

      if result.empty?
        raise "No result found for '#{place}'"
      end

      {latitude: result.first.latitude,
       longitude: result.first.longitude}
    end
  end
end
