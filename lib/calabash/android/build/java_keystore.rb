require 'escape'

module Calabash
  module Android
    module Build
      # @!visibility private
      class JavaKeystore
        # @!visibility private
        CALABASH_KEYSTORE_SETTINGS_FILENAME = 'calabash_keystore_settings.json'

        attr_reader :errors, :location, :keystore_alias, :store_password
        attr_reader :key_password, :fingerprint, :signature_algorithm_name

        def initialize(location, keystore_alias, store_password, key_password, options={})
          @logger = options[:logger] || Calabash::Logger.new

          raise "No such keystore file '#{location}'" unless File.exists?(File.expand_path(location))

          if key_password.nil? || key_password.empty?
            key_password = store_password.dup
          end

          @logger.log "Reading keystore data from keystore file '#{File.expand_path(location)}'", :debug

          keystore_data = system_with_stdout_on_success(Environment.keytool_path, '-list', '-v', '-alias', keystore_alias, '-keystore', location, '-storepass', store_password, '-keypass', key_password, '-J"-Dfile.encoding=utf-8"')

          if keystore_data.nil?
            if keystore_alias.empty?
              @logger.log "Could not obtain keystore data. Will try to extract alias automatically", :debug

              keystore_data = system_with_stdout_on_success(Environment.keytool_path, '-list', '-v', '-keystore', location, '-storepass', store_password, '-keypass', key_password, '-J"-Dfile.encoding=utf-8"')

              if keystore_data.nil?
                error = 'Could not read keystore alias. Probably because the credentials were incorrect.'
                @errors = [{message: error}]
                @logger.log error, :error
                raise error
              end

              aliases = keystore_data.scan(/Alias name\:\s*(.*)/).flatten

              if aliases.length == 0
                raise 'Could not extract alias automatically. Please specify alias using calabash setup-keystore'
              elsif aliases.length > 1
                raise 'Multiple aliases found in keystore. Please specify alias using calabash setup-keystore'
              else
                keystore_alias = aliases.first
                @logger.log "Extracted keystore alias '#{keystore_alias}'. Continuing", :debug

                return initialize(location, keystore_alias, store_password, key_password)
              end
            else
              error = "Could not list certificates in keystore. Probably because the credentials were incorrect."
              @errors = [{:message => error}]
              @logger.log error, :error
              raise error
            end
          end

          @location = location
          @keystore_alias = keystore_alias
          @store_password = store_password
          @key_password = key_password
          @logger.log "Key store data:", :debug
          @logger.log keystore_data, :debug
          @fingerprint = JavaKeystore.extract_md5_fingerprint(keystore_data)
          @signature_algorithm_name = JavaKeystore.extract_signature_algorithm_name(keystore_data)
          @logger.log "Fingerprint: #{fingerprint}", :debug
          @logger.log "Signature algorithm name: #{signature_algorithm_name}", :debug
        end

        # @!visibility private
        def sign_apk(apk_path, dest_path)
          raise "Cannot sign with a miss configured keystore" if errors
          raise "No such file: #{apk_path}" unless File.exists?(apk_path)

          # E.g. MD5withRSA or MD5withRSAandMGF1
          encryption = signature_algorithm_name.split('with')[1].split('and')[0]
          signing_algorithm = "SHA1with#{encryption}"
          digest_algorithm = 'SHA1'

          Logger.info "Signing using the signature algorithm: '#{signing_algorithm}'"
          Logger.info "Signing using the digest algorithm: '#{digest_algorithm}'"

          unless system_with_stdout_on_success(Environment.jarsigner_path, '-sigfile', 'CERT', '-sigalg', signing_algorithm, '-digestalg', digest_algorithm, '-signedjar', dest_path, '-storepass', store_password, '-keypass', key_password, '-keystore',  location, apk_path, keystore_alias)
            Logger.error 'Could not sign the application. The keystore credentials are most like incorrect'
            raise "Could not sign app '#{apk_path}'"
          end
        end

        # @!visibility private
        def system_with_stdout_on_success(cmd, *args)
          a = Escape.shell_command(args)
          cmd = "#{cmd} #{a.gsub("'", '"')}"
          @logger.log cmd, :debug
          out = `#{cmd}`
          if $?.exitstatus == 0
            out
          else
            nil
          end
        end

        # @!visibility private
        def fail_wrong_info
          raise "Could not read keystore with the given credentials. Please ensure "
        end

        # @!visibility private
        def self.read_keystore_with_default_password_and_alias(path)
          path = File.expand_path path

          if File.exists? path
            keystore = nil

            begin
              keystore = JavaKeystore.new(path, 'androiddebugkey', 'android', 'android')
            rescue => _
              Logger.debug "Trying to read keystore from: #{path} - got error"
              return nil
            end

            if keystore.errors
              Logger.debug "Got errors #{keystore.errors}"
              nil
            else
              Logger.debug "Unlocked keystore at #{path} - fingerprint: #{keystore.fingerprint}"
              keystore
            end
          else
            Logger.debug "Trying to read keystore from: #{path} - no such file"
            nil
          end
        end

        # @!visibility private
        def self.get_keystores
          if keystore = keystore_from_settings
            [ keystore ]
          else
            [
                read_keystore_with_default_password_and_alias(File.join(ENV["HOME"], "/.android/debug.keystore")),
                read_keystore_with_default_password_and_alias("debug.keystore"),
                read_keystore_with_default_password_and_alias(File.join(ENV["HOME"], ".local/share/Xamarin/Mono\\ for\\ Android/debug.keystore")),
                read_keystore_with_default_password_and_alias(File.join(ENV["HOME"], "AppData/Local/Xamarin/Mono for Android/debug.keystore")),
            ].compact
          end
        end

        # @!visibility private
        def self.keystore_from_settings
          if File.exist?(CALABASH_KEYSTORE_SETTINGS_FILENAME)
            Logger.info "Reading keystore information specified in #{CALABASH_KEYSTORE_SETTINGS_FILENAME}"

            begin
              keystore = JSON.parse(IO.read(CALABASH_KEYSTORE_SETTINGS_FILENAME))
            rescue JSON::ParserError => e
              Logger.error("Could not parse keystore settings. Please run #{Calabash::Utility.bundle_exec_prepend}calabash setup-keystore again")

              raise e
            end

            JavaKeystore.new(keystore["keystore_location"], keystore["keystore_alias"], keystore["keystore_store_password"], keystore["keystore_key_password"])
          end
        end

        # @!visibility private
        def self.fail_if_key_missing(map, key)
          raise "Found #{CALABASH_KEYSTORE_SETTINGS_FILENAME} but no #{key} defined." unless map[key]
        end

        # @!visibility private
        def self.extract_md5_fingerprint(fingerprints)
          m = fingerprints.scan(/MD5.*((?:[a-fA-F\d]{2}:){15}[a-fA-F\d]{2})/).flatten
          raise "No MD5 fingerprint found:\n #{fingerprints}" if m.empty?
          m.first
        end

        # @!visibility private
        def self.extract_signature_algorithm_name(fingerprints)
          m = fingerprints.scan(/Signature algorithm name: (.*)/).flatten
          raise "No signature algorithm names found:\n #{fingerprints}" if m.empty?
          m.first
        end
      end
    end
  end
end
