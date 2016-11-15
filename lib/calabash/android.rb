module Calabash
  # @!visibility private
  module AndroidInternal
    require 'calabash'

    require 'calabash/android/environment'
    require 'calabash/android/application'
    require 'calabash/android/build'
    require 'calabash/android/device'
    require 'calabash/android/screenshot'
    require 'calabash/android/server'
    require 'calabash/android/adb'
    require 'calabash/android/gestures'
    require 'calabash/android/interactions'
    require 'calabash/android/orientation'
    require 'calabash/android/physical_buttons'
    require 'calabash/android/text'
    require 'calabash/android/web'
    require 'calabash/android/console_helpers'
    require 'calabash/android/life_cycle'
    require 'calabash/android/scroll'

    include Calabash::Android::Gestures
    include Calabash::Android::Interactions
    include Calabash::Android::LifeCycle
    include Calabash::Android::Orientation
    include Calabash::Android::PhysicalButtons
    include Calabash::Android::Text
    include Calabash::Android::Scroll
    include Calabash::Android::Web
  end

  # Contains the Android implementations of the Calabash APIs.
  module Android
    # @!visibility private
    TEST_SERVER_CODE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'android', 'test-server')
    # @!visibility private
    UNSIGNED_TEST_SERVER_APK = File.join(File.dirname(__FILE__), 'android', 'lib', 'TestServer.apk')
    # @!visibility private
    ANDROID_MANIFEST_PATH = File.join(File.dirname(__FILE__), 'android', 'lib', 'AndroidManifest.xml')
    # @!visibility private
    HELPER_APPLICATION = File.join(File.dirname(__FILE__), 'android', 'lib', 'HelperApplication.apk')
    # @!visibility private
    HELPER_APPLICATION_TEST_SERVER = File.join(File.dirname(__FILE__), 'android', 'lib', 'HelperApplicationTestServer.apk')

    # @!visibility private
    def self.extended(base)
      Calabash.send(:extended, base)
    end

    # @!visibility private
    def self.included(base)
      Calabash.send(:included, base)
    end

    require 'calabash'
    # Hide from documentation
    send(:include, Calabash)

    require 'calabash/android/defaults'
    extend Calabash::Android::Defaults

    include ::Calabash::AndroidInternal

    # @!visibility private
    def self.binary_location(name, abi, using_pie)
      binary_name = if using_pie
                      "#{name}-pie"
                    else
                      name
                    end

      file = File.join(File.dirname(__FILE__), 'android', 'lib', name, abi, binary_name)

      unless File.exist?(file)
        raise "No such file '#{file}'"
      end

      file
    end

    require 'calabash/android/legacy'
  end
end

unless Calabash::Environment.variable("CAL_NO_DEPENDENCIES") == "1"
  # Setup environment on load
  Calabash::Android::Environment.setup
end

# @!visibility private
class CalabashAndroidMethodsInternal
  include ::Calabash::Android
end

# @!visibility private
class CalabashAndroidMethods < BasicObject
  include ::Calabash::AndroidInternal

  instance_methods.each do |method_name|
    define_method(method_name) do |*args, &block|
      ::CalabashAndroidMethodsInternal.new.send(method_name, *args, &block)
    end
  end
end

# Setup the default device, if it fails, keep it as a message to display later
Calabash::Internal.save_setup_default_device_error do
  Calabash::Android.setup_default_device!
end

# Returns a object that exposes all of the public Calabash Android API.
# This method should *always* be used to access the Calabash API. By default,
# all methods are executed using the default device and the default
# application.
#
# For iOS specific methods use {cal_ios}. For cross-platform methods use {cal}.
#
# All Android API methods are available with documentation in
# {Calabash::Android}
#
# @see Calabash::Android
#
# @return [Object] Instance responding to all Calabash Android methods
#  in the API.
def cal_android
  CalabashAndroidMethods.new
end

# We also want to patch `cal` to invoke the Android implementations
class CalabashMethodsInternal
  include ::Calabash::Android

  instance_methods.each do |method_name|
    define_method(method_name) do |*args, &block|
      ::CalabashAndroidMethodsInternal.new.send(method_name, *args, &block)
    end
  end
end

if defined?(::Calabash::IOSInternal)
  raise Calabash::RequiredBothPlatformsError, "Cannot require both calabash/android and calabash/ios"
end
