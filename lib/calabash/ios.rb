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

    require 'calabash/ios/environment'
    require 'calabash/ios/device'
    require 'calabash/ios/operations'
    require 'calabash/ios/server'
    require 'calabash/ios/application'

    include Calabash::IOS::Operations
  end
end
