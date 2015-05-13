require 'run_loop'

if RunLoop.const_defined?(:Ipa)
  "\033[34mRunLoop::Ipa patch can be removed.\033[0m"
else
  "\033[34mApplying RunLoop::Ipa patch.\033[0m"
  module RunLoop
    # A model of the an .ipa - a application binary for iOS devices.
    class Ipa


      # The path to this .ipa.
      # @!attribute [r] path
      # @return [String] A path to this .ipa.
      attr_reader :path

      # The bundle identifier of this ipa.
      # @!attribute [r] bundle_identifier
      # @return [String] The bundle identifier of this ipa; obtained by inspecting
      #  the app's Info.plist.
      attr_reader :bundle_identifier

      # Create a new ipa instance.
      # @param [String] path_to_ipa The path the .ipa file.
      # @return [Calabash::Ipa] A new ipa instance.
      # @raise [RuntimeError] If the file does not exist.
      # @raise [RuntimeError] If the file does not end in .ipa.
      def initialize(path_to_ipa)
        unless File.exist? path_to_ipa
          raise "Expected an ipa at '#{path_to_ipa}'"
        end

        unless path_to_ipa.end_with?('.ipa')
          raise "Expected '#{path_to_ipa}' to be an ipa"
        end
        @path = path_to_ipa
      end

      # @!visibility private
      def to_s
        "#<Ipa: #{bundle_identifier}: '#{path}'>"
      end

      # The bundle identifier of this ipa.
      # @return [String] A string representation of this ipa's CFBundleIdentifier
      # @raise [RuntimeError] If ipa does not expand into a Payload/<app name>.app
      #  directory.
      # @raise [RuntimeError] If an Info.plist does exist in the .app.
      def bundle_identifier
        unless File.exist?(bundle_dir)
          raise "Expected a '#{File.basename(path).split('.').first}.app'\nat path '#{payload_dir}'"
        end

        @bundle_identifier ||= lambda {
          info_plist_path = File.join(bundle_dir, 'Info.plist')
          unless File.exist? info_plist_path
            raise "Expected an 'Info.plist' at '#{bundle_dir}'"
          end
          pbuddy = RunLoop::PlistBuddy.new
          pbuddy.plist_read('CFBundleIdentifier', info_plist_path)
        }.call
      end

      private

      def tmpdir
        @tmpdir ||= Dir.mktmpdir
      end

      def payload_dir
        @payload_dir ||= lambda {
          FileUtils.cp(path, tmpdir)
          zip_path = File.join(tmpdir, File.basename(path))
          Dir.chdir(tmpdir) do
            system('unzip', *['-q', zip_path])
          end
          File.join(tmpdir, 'Payload')
        }.call
      end

      def bundle_dir
        @bundle_dir ||= lambda {
          Dir.glob(File.join(payload_dir, '*')).detect {|f| File.directory?(f) && f.end_with?('.app')}
        }.call
      end
    end
  end
end
