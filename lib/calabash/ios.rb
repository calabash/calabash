module Calabash
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

    # Include old methods
    require_old File.join('calabash-cucumber', 'lib', 'calabash-cucumber')
    include Calabash::IOS::Operations

    require 'calabash/ios/environment'
    require 'calabash/ios/device'
    require 'calabash/ios/operations'
    require 'calabash/ios/server'
    require 'calabash/ios/application'
  end
end
