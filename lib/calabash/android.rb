module Calabash
  # Contains the Android implementations of the Calabash APIs.
  module Android
    TEST_SERVER_CODE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'android', 'test-server')
    UNSIGNED_TEST_SERVER_APK = File.join(File.dirname(__FILE__), 'android', 'lib', 'TestServer.apk')

    require File.join(File.dirname(__FILE__), '..', '..', 'script', 'backwards_compatibility')

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

    require 'calabash/android/environment'

    # Include old methods
    require_old File.join('ruby-gem', 'lib', 'calabash-android')
    include Calabash::Android::Operations

    require 'calabash/android/application'
    require 'calabash/android/build'
    require 'calabash/android/device'
    require 'calabash/android/screenshot'
    require 'calabash/android/server'
    require 'calabash/android/adb'
    require 'calabash/android/gestures'
    require 'calabash/android/text'

    include Calabash::Android::Gestures
    include Calabash::Android::Text
  end
end
