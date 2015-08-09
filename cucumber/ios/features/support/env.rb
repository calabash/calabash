require 'calabash/ios'

World(Calabash::IOS)

Calabash::IOS.setup_defaults!

unless Calabash::Environment.xamarin_test_cloud?
  require 'pry'
  Pry.config.history.file = '.pry-history'
  require 'pry-nav'
end
