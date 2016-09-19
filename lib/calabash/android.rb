module Calabash
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

    require 'calabash/android/defaults'
    extend Calabash::Android::Defaults

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
