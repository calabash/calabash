module Calabash
  # @!visibility private
  module IOSInternal
    require 'calabash'

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
    require 'calabash/ios/gestures'
    require 'calabash/ios/slider'
    require 'calabash/ios/date_picker'

    include Calabash::IOS::Conditions
    include Calabash::IOS::Orientation
    include Calabash::IOS::Interactions
    include Calabash::IOS::Text
    include Calabash::IOS::UIA
    include Calabash::IOS::Scroll
    include Calabash::IOS::Runtime
    include Calabash::IOS::Gestures
    include Calabash::IOS::Slider
    include Calabash::IOS::DatePicker
  end

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

    include ::Calabash::IOSInternal

    require 'calabash/ios/defaults'
    extend Calabash::IOS::Defaults

    require 'calabash/ios/legacy'
  end
end

# @!visibility private
class CalabashIOSMethodsInternal
  include ::Calabash::IOS
end

# @!visibility private
class CalabashIOSMethods < BasicObject
  include ::Calabash::IOSInternal

  instance_methods.each do |method_name|
    define_method(method_name) do |*args, &block|
      ::CalabashIOSMethodsInternal.new.send(method_name, *args, &block)
    end
  end
end

def cal_ios
  CalabashIOSMethods.new
end

# We also want to patch `cal` to invoke the iOS implementations
class CalabashMethodsInternal
  include ::Calabash::IOS

  instance_methods.each do |method_name|
    define_method(method_name) do |*args, &block|
      ::CalabashIOSMethodsInternal.new.send(method_name, *args, &block)
    end
  end
end

if defined?(::Calabash::AndroidInternal)
  raise Calabash::RequiredBothPlatformsError, "Cannot require both calabash/android and calabash/ios"
end
