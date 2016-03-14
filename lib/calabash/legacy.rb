if Calabash::Environment.variable('TEST_APP_PATH')
  Calabash::Logger.warn("Deprecated use of old ENV variable 'TEST_APP_PATH'")
  Calabash::Environment::TEST_SERVER_PATH =
      Calabash::Environment.variable('TEST_APP_PATH')
end

if Calabash::Environment.variable('APP_PATH')
  Calabash::Logger.warn("Deprecated use of old ENV variable 'APP_PATH'")
  Calabash::Environment::APP_PATH = Calabash::Environment.variable('APP_PATH')
end