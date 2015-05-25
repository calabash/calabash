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

    # @todo Should we restrict access to some class and modules?
    #
    # For example, I don't want casual users to have automatic access to the
    # RuntimeInfo class or the MapRoute module.

    require 'calabash/ios/runtime_attributes'
    require 'calabash/ios/routes/map_route'

    require 'calabash/ios/environment'
    require 'calabash/ios/physical_device_mixin'
    require 'calabash/ios/device'
    require 'calabash/ios/operations'
    require 'calabash/ios/server'
    require 'calabash/ios/application'

    include Calabash::IOS::Operations
  end
end
