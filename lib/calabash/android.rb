module Calabash
  module Android
    TEST_SERVER_CODE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'android', 'test-server')
    UNSIGNED_TEST_SERVER_APK = File.join(File.dirname(__FILE__), 'android', 'lib', 'TestServer.apk')

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
    require 'calabash/android/operations'
    require 'calabash/android/device'
    require 'calabash/android/screenshot'
    require 'calabash/android/server'
  end
end