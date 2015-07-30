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

    require 'calabash/ios/defaults'
    extend Calabash::IOS::Defaults

    require 'calabash/ios/environment'
    require 'calabash/ios/application'
    require 'calabash/ios/device'
    require 'calabash/ios/conditions'
    require 'calabash/ios/interactions'
    require 'calabash/ios/orientation'
    require 'calabash/ios/server'
    require 'calabash/ios/text'
    require 'calabash/ios/console_helpers'
    require 'calabash/ios/uia'
    require 'calabash/ios/scroll'
    require 'calabash/ios/runtime'

    include Calabash::IOS::Conditions
    include Calabash::IOS::Orientation
    include Calabash::IOS::Interactions
    include Calabash::IOS::Text
    include Calabash::IOS::UIA
    include Calabash::IOS::Scroll
    include Calabash::IOS::Runtime

  end
end
