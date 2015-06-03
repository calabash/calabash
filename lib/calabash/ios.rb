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
    require 'calabash/ios/api'
    require 'calabash/ios/server'
    require 'calabash/ios/application'
    require 'calabash/ios/device'
  end
end
