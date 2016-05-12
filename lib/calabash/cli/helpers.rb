module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Helpers
      # @!visibility private
      HELP = {
          help: 'help',
          generate: 'generate',
          run: 'run [application] [cucumber options]',
          console: 'console [application]',
          doctor: 'doctor [setup]',
          version: 'version',
          setup_keystore: 'setup-keystore',
          resign: 'resign <apk>',
          build: 'build <apk>'
      }

      # @!visibility private
      def key_for_command(command)
        HELP.each do |key, value|
          if value.split(' ').first == command
            return key
          end
        end

        nil
      end

      # @!visibility private
      def print_usage_for(key, output=STDOUT)
        if key.nil? || HELP[key].nil?
          output.write <<EOF
No such command '#{key}'
EOF
        else
          output.write <<EOF
Usage:
  calabash [options] #{HELP[key]}
EOF
        end
      end

      # @!visibility private
      def print_usage(output=STDOUT)
          output.write <<EOF
  Usage: calabash [options] <command-name> [command specific options]
  <command-name> can be one of
    #{HELP[:help]} [command]
      print help information.

    #{HELP[:generate]}
      generate a Cucumber project folder structure.

    #{HELP[:run]}
      runs Cucumber in the current folder with the environment needed.
      the cucumber options will be passed unchanged to cucumber

    #{HELP[:console]}
      starts an interactive console to interact with your app via Calabash

    #{HELP[:doctor]}
      diagnoses and fixes problems with your setup

    #{HELP[:version]}
      prints the gem version

    Android specific commands
      #{HELP[:setup_keystore]}
        sets up a non-default keystore to use with this test project.

      #{HELP[:resign]}
        resigns the app with the currently configured keystore.

      #{HELP[:build]} [-o <output_file>]
        builds the test server that will be used when testing the app.

    iOS specific commands
      setup <path>
        setup your XCode project for calabash-ios (EXPERIMENTAL)

      check <{path to .ipa|<path to .app}>
        check whether an app or ipa is linked with calabash.framework (EXPERIMENTAL)

      download
        install latest compatible version of calabash.framework

      check <{path to .ipa|path to .app}>
        check whether an app or ipa is linked with calabash.framework

      sim locale <lang> [region]
        change locale and regional settings in all iOS Simulators

      sim location <{on|off}> [path to .app]
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

      # @!visibility private
      def help
        file_name = File.join(File.dirname(__FILE__), '..', 'doc', 'calabash_help.txt')
        system("less \"#{file_name}\"")
      end

      # @!visibility private
      def fail(reason, command=nil)
        STDERR.write("#{reason}\n")

        if command != nil
          print_usage_for(command)
        end

        exit(1)
      end
    end
  end
end

# Removed commands
=begin
iOS:
    update [target]
      updates one of the following targets: hooks



=end
