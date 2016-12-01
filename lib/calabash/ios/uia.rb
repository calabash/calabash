module Calabash
  module IOS

    # Methods for interacting directly with Apple's UIAutomation API.
    #
    # https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html
    # https://developer.apple.com/library/ios/documentation/DeveloperTools/Reference/UIAutomationRef/
    #
    # Calabash iOS uses this API to perform gestures.  It is sometimes helpful
    # to drop down into this API to explore your app.
    module UIA

      # Evaluates `script` using Apples's UIAutomation API.
      #
      # @example
      #  uia("UIATarget.localTarget().shake()")
      #  uia("UIATarget.localTarget().frontMostApp().keyboard().buttons()['Delete']")
      #  uia("UIATarget.localTarget().frontMostApp().mainWindow().elements()")
      def uia(script)
        Calabash::Internal.with_current_target(required_os: :ios) {|target| target.evaluate_uia(script)}
      end

      # Evaluates `script` after prefixing with "UIATarget.localTarget()"
      #
      # @example
      #  uia_with_target("shake()")
      def uia_with_target(script)
        uia("UIATarget.localTarget().#{script}")
      end

      # Evaluates `script` after prefixing with
      # "UIATarget.localTarget().frontMostApp()"
      #
      # @example
      #  uia_with_app("keyboard().buttons()['Delete'])
      def uia_with_app(script)
        uia("UIATarget.localTarget().frontMostApp().#{script}")
      end

      # Evaluates `script` after prefixing with
      # "UIATarget.localTarget().frontMostApp().mainWindow()"
      def uia_with_main_window(script)
        uia("UIATarget.localTarget().frontMostApp().mainWindow().#{script}")
      end
    end
  end
end
