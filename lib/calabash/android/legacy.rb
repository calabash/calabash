if Calabash::Envrionment.variable('DEVICE_ENDPOINT')
  Calabash::Android::Environment::DEVICE_ENDPOINT =
      URI.parse(Calabash::Envrionment.variable('DEVICE_ENDPOINT'))
end
