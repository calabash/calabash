module Calabash
  class Device
    include Utility

    def install(args)
      abstract_method!
    end

    def uninstall(args)
      abstract_method!
    end
  end
end