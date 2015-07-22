module Calabash
  module IOS
    module UIA

      # Evaluates `script` with Apple's UIAutomation API.
      #
      def uia(script)
        Device.default.evaluate_uia(script)
      end

      def uia_with_target(script)
        uia("UIATarget.localTarget().#{script}")
      end

      def uia_with_app(script)
        uia("UIATarget.localTarget().frontMostApp().#{script}")
      end

      def uia_with_main_window(script)
        uia("UIATarget.localTarget().frontMostApp().mainWindow().#{script}")
      end
    end
  end
end
