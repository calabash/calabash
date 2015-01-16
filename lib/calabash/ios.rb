module Calabash
  module IOS
    require 'calabash'
    include Calabash

    # Include old methods
    require_old File.join('calabash-cucumber', 'lib', 'calabash-cucumber')
    include Calabash::IOS::Operations

    require 'calabash/ios/device'
    require 'calabash/ios/operations'
  end
end