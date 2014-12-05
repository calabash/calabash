module Calabash
  module IOS
    require 'calabash'
    require_old File.join('calabash-cucumber', 'lib', 'calabash-cucumber')

    include Calabash
  end
end