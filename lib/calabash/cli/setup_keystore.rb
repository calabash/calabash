require 'json'
require 'awesome_print'
require 'io/console'

module Calabash
  module CLI
    # @!visibility private
    module SetupKeystore
      # @!visibility private
      def parse_setup_keystore_arguments!
        set_platform!(:android)

        settings = {}

        puts "Please enter keystore information to use a custom keystore instead of the default"

        settings[:keystore_location] = File.expand_path(prompt('Please enter a path to the keystore'))
        settings[:keystore_store_password] = prompt('Please enter the password for the keystore (storepass)', true)
        settings[:keystore_alias] = prompt('Please enter the alias. Leave blank for auto-detection.')
        settings[:keystore_key_password] = prompt('Please enter the password for the key (keypass). Leave blank if it is the same as the store password.', true)

        File.open(Android::Build::JavaKeystore::CALABASH_KEYSTORE_SETTINGS_FILENAME, 'w') do |file|
          file.puts(JSON.pretty_generate(settings))
        end

        puts "Saved your settings to '#{Android::Build::JavaKeystore::CALABASH_KEYSTORE_SETTINGS_FILENAME}'. You can edit the settings manually or run this setup script again"
      end
    end
  end
end
