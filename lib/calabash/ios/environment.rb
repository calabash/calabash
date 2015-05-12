module Calabash
  module IOS
    class Environment < Calabash::Environment
      DEVICE_ENDPOINT = URI.parse((variable('CAL_ENDPOINT') || 'http://localhost:37265'))
    end
  end
end

