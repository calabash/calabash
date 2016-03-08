module Calabash
  module IOS

    # A class to represent an iOS application.  An application can be a
    # simulator bundle (.app) or a device binary (.ipa).
    class Application < Calabash::Application

      # The path to the application under test deduced by analysing the
      # environment.
      #
      # You can control the default application path by setting the `CAL_APP`
      # environment variable.  This is the best way of ensuring Calabash
      # can find your application.
      #
      # @todo We have a chicken and egg problem.  If the device under test
      # is a simulator, we have been analyzing the Xcode or Xamarin Studio
      # project for the likely location of the .app.  I think we still want
      # to do this.  The problem is that Xcode buries the .app in a
      # DerivedData directory deep in the user's ~/Library/ and the correct
      # directory path is very difficult to find.  I overcome this problem
      # with command-line build scripts that put the .app (or .ipa) in a
      # directory local to my project.  Others devs use Xcode Custom Build
      # locations.  I don't think we we want to branch here on whether or not
      # the DEVICE_ID points to a simulator or physical device.  This is
      # wicked expensive.
      def self.default_from_environment
        application_path = Environment::APP_PATH

        if application_path.nil?
          raise 'No application path is set. Specify application with environment variable CAL_APP'
        end

        Application.new(application_path)
      end

      # Create a new Application.
      #
      # @param [String] application_path The path to the ipa or app.
      # @param [Hash] options Optional arguments.
      # @option options [Calabash::Logger] :logger An optional logger.  It is
      #  not recommended that you set this yourself.
      # @return [Calabash::IOS::Application] A new application.
      # @raise [RuntimeError] If the `application_path` does not indicate a
      #  file that exists.
      # @raise [RuntimeError] If the `application_path` does not end with .ipa
      #  or .app.
      def initialize(application_path, options = {})
        super(application_path, options)

        @simulator_bundle = File.extname(path) == '.app'
        @device_binary = File.extname(path) == '.ipa'

        unless @simulator_bundle || @device_binary
          raise "Expected #{path} to be an .ipa or .app, but found '#{File.extname(path)}'"
        end
      end

      # Return true if this application is for an iOS Simulator.
      # @return [Boolean] Is this a .app?
      def simulator_bundle?
        @simulator_bundle
      end

      # Return true if this application is for a physical iOS device.
      # @return [Boolean] Is this a .ipa?
      def device_binary?
        @device_binary
      end

      # Is this application an iOS application
      #
      # @return [Boolean] Always returns true
      def ios_application?
        true
      end

      # Returns the sha1 of the directory or binary of this app's path.
      # @return [String] A checksum.
      def sha1
        RunLoop::Directory.directory_digest(path)
      end

      # Does this app have the same checksum as another app?
      # @param [Calabash::IOS::Application] other The other app to compare to.
      # @return [Boolean] Is the checksum the same for the two apps?
      def same_sha1_as?(other)
        sha1 == other.sha1
      end

      private

      # @!visibility private
      def run_loop_ipa
        @run_loop_ipa ||= lambda do
          if device_binary?
            RunLoop::Ipa.new(path)
          else
            nil
          end
        end.call
      end

      # @!visibility private
      def run_loop_app
        @run_loop_app ||= lambda do
          if simulator_bundle?
            RunLoop::App.new(path)
          else
            nil
          end
        end.call
      end

      # @!visibility private
      def extract_identifier
        if simulator_bundle?
          run_loop_app.bundle_identifier
        elsif device_binary?
          run_loop_ipa.bundle_identifier
        else
          raise "Unknown app type '#{File.extname(path)}', cannot extract bundle identifier"
        end
      end
    end
  end
end
