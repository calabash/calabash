if ENV["APP_PATH"]
  Calabash::Environment::APP_PATH = ENV["APP_PATH"]
end

if ENV["TEST_APP_PATH"]
  Calabash::Environment::TEST_SERVER_PATH = ENV["TEST_APP_PATH"]
end

if ENV['DEVICE_ENDPOINT']
  Calabash::Android::Environment::DEVICE_ENDPOINT = URI.parse(ENV['DEVICE_ENDPOINT'])
end
