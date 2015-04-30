module Calabash
  module Android
    module Operations
      def _reinstall(opt={})
        uninstall(Application.default)
        install(Application.default)
      end
    end
  end
end
