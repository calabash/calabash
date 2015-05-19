require 'calabash'
require 'calabash/ios'

World(Calabash::IOS)

Calabash::Application.default = Calabash::IOS::Application.default_from_environment

identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
server = Calabash::IOS::Server.default

Calabash::Device.default = Calabash::IOS::Device.new(identifier, server)
