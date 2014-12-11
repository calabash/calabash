module Calabash
  module IOS
    require 'calabash'

    # Include old methods
    require_old File.join('calabash-cucumber', 'lib', 'calabash-cucumber')
    include Calabash::IOS::Operations

    include Calabash
  end
end