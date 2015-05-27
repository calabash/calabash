module Calabash
  # Contains the iOS implementations of the Calabash APIs.
  module IOS
    require 'calabash'
    include Calabash

    # @!visibility private
    def self.extended(base)
      Calabash.send(:extended, base)
    end

    # @!visibility private
    def self.included(base)
      Calabash.send(:included, base)
    end

    require 'calabash/ios/runtime_attributes'
    require 'calabash/ios/routes/error'
    require 'calabash/ios/routes/route_mixin'
    require 'calabash/ios/routes/map_route'
    require 'calabash/ios/routes/uia_route'

    require 'calabash/ios/gestures'

    require 'calabash/ios/status_bar'

    require 'calabash/ios/environment'
    require 'calabash/ios/physical_device_mixin'
    require 'calabash/ios/device/device'
    require 'calabash/ios/operations'
    require 'calabash/ios/server'
    require 'calabash/ios/application'

    include Calabash::IOS::Operations
  end
end
