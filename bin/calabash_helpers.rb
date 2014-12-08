module Calabash
  module CLI
    module Helpers
      def print_usage(output=STDOUT)
          output.write <<EOF
  Usage: calabash [options] <command-name> [command specific options]
  <command-name> can be one of
    help
      prints more detailed help information.
    gen <platform>
      generate a features folder structure based on the specified platform.
      can be either 'android', 'ios' or 'cross-platform'
    run <application> [cucumber options]
      runs Cucumber in the current folder with the environment needed.
      the cucumber options will be passed unchanged to cucumber
    console [application]
      starts an interactive console to interact with your app via Calabash
    version
      prints the gem version

    Android specific commands
      setup
        sets up a non-default keystore to use with this test project.
      resign <apk>
        resigns the app with the currently configured keystore.
      build <apk>
        builds the test server that will be used when testing the app.

    iOS specific commands
      setup [<path>]
        setup your XCode project for calabash-ios (EXPERIMENTAL)

      check [{<path to .ipa>|<path to .app>}]
        check whether an app or ipa is linked with calabash.framework (EXPERIMENTAL)

      sim locale <lang> [<region>]
        change locale and regional settings in all iOS Simulators

      sim location {on|off} [path to .app]
        set allow location on/off for current project or app

      sim reset
        reset content and settings in all iOS Simulators

      sim acc
        enable accessibility in all iOS Simulators

      sim device {iPad|iPad_Retina|iPhone|iPhone_Retina|iPhone_Retina_4inch}
        change the default iOS Simulator device.

  [options] can be
    -v, --verbose
      Turns on verbose logging
EOF
      end

      def help
        file_name = File.join(File.dirname(__FILE__), '..', 'doc', 'calabash_help.txt')
        system("less \"#{file_name}\"")
      end
    end
  end
end

# Removed commands
=begin
iOS:
    update [target]
      updates one of the following targets: hooks

    download
      install latest compatible version of calabash.framework

check [{<path to .ipa>|<path to .app>}]
check whether an app or ipa is linked with calabash.framework (EXPERIMENTAL)
=end
