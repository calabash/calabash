module Calabash
  module Build
    ROOT = File.join(File.dirname(__FILE__), '..')

    require File.join(File.dirname(__FILE__), 'android_test_server.rb')
  end
end
