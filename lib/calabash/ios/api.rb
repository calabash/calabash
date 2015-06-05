module Calabash
  module IOS
    module API
      require 'calabash/api'
      require 'calabash/gestures'
      require 'calabash/wait'
      require 'calabash/ios/api/keyboard'
      require 'calabash/ios/api/status_bar'
      require 'calabash/ios/api/text'

      include Calabash::API
    end
  end
end
