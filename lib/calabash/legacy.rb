if Calabash::Envrionment.variable('TEST_APP_PATH')
  Calabash::Environment::TEST_SERVER_PATH = Calabash::Envrionment.variable('TEST_APP_PATH')
end

if Calabash::Envrionment.variable('APP_PATH')
  Calabash::Environment::APP_PATH = Calabash::Envrionment.variable('APP_PATH')
end