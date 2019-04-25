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
    require 'calabash/ios/scroll'
    require 'calabash/ios/runtime'
    require 'calabash/ios/gestures'
    require 'calabash/ios/slider'
    require 'calabash/ios/date_picker'
    require 'calabash/ios/automator'
    require 'calabash/ios/web'

    include Calabash::IOS::Conditions
    include Calabash::IOS::Orientation
    include Calabash::IOS::Interactions
    include Calabash::IOS::Text
    include Calabash::IOS::Scroll
    include Calabash::IOS::Runtime
    include Calabash::IOS::Gestures
    include Calabash::IOS::Slider
    include Calabash::IOS::DatePicker
    include Calabash::IOS::Web
  end

  # Contains the iOS implementations of the Calabash APIs.
  module IOS
    require 'calabash'
    # Hide from documentation
    send(:include, Calabash)

    # @!visibility private
    def self.extended(base)
      Calabash.send(:extended, base)
    end

    # @!visibility private
    def self.included(base)
      Calabash.send(:included, base)
    end

    include ::Calabash::IOSInternal

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

# Set the default target state to the Android default targets
Calabash::Internal.default_target_state = Calabash::TargetState::DefaultTargetState.new(
    device_from_environment: lambda do
      server = Calabash::IOS::Server.default
      identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::IOS::Application.default_from_environment)

      Calabash::IOS::Device.new(identifier, server)
    end,
    target_from_environment: lambda do |device|
      application = Calabash::IOS::Application.default_from_environment
      Calabash::Target.new(device, application)
    end
)

# Returns a object that exposes all of the public Calabash iOS API.
# This method should *always* be used to access the Calabash API. By default,
# all methods are executed using the default device and the default
# application.
#
# For iOS specific methods use {cal_android}. For cross-platform methods use
# {cal}.
#
# All iOS API methods are available with documentation in {Calabash::IOS}
#
# @see Calabash::IOS
#
# @return [CalabashIOSMethods] Instance responding to all Calabash iOS methods
#  in the API.
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
