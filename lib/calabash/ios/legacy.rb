if Calabash::Envrionment.variable('DEVICE_ENDPOINT')
  Calabash::IOS::Environment::DEVICE_ENDPOINT =
      URI.parse(Calabash::Envrionment.variable('DEVICE_ENDPOINT'))
end
