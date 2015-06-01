require 'calabash'
require 'calabash/android'

World(Calabash::Android)

identifier = Calabash::Android::Device.default_serial
server = Calabash::Android::Server.default

Calabash::Device.default = Calabash::Android::Device.new(identifier, server)

Calabash::Application.default = Calabash::Android::Application.default_from_environment

unless Calabash::Environment.xamarin_test_cloud?
  require 'pry'
end
