require 'calabash/ios'

World(Calabash::IOS)

unless Calabash::Environment.xamarin_test_cloud?
  require 'pry'
  Pry.config.history.file = '.pry-history'
  require 'pry-nav'
end
