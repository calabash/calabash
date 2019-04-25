require 'calabash'

begin
  require 'calabash/android'
  require 'calabash/ios'
rescue Calabash::RequiredBothPlatformsError
end

World(Calabash)