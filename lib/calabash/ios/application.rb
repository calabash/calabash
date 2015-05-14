module Calabash
  module IOS
    class Application < Calabash::Application
      def self.default_from_environment
        application_path = Environment::APP_PATH

        if application_path.nil?
          raise 'No application path is set'
        end

        Application.new(application_path)
      end

      def initialize(application_path, options = {})
        super(application_path, options)

        @simulator_bundle = File.extname(path) == '.app'
        @device_binary = File.extname(path) == '.ipa'

        unless @simulator_bundle || @device_binary
          raise "Expected #{path} to be an .ipa or .app, but found '#{File.extname(path)}'"
        end
      end

      def simulator_bundle?
        @simulator_bundle
      end

      def device_binary?
        @device_binary
      end

      def sha1
        RunLoop::Directory.directory_digest(path)
      end

      def same_sha1_as?(other)
        sha1 == other.sha1
      end

      private

      def run_loop_ipa
        @run_loop_ipa ||= lambda do
          if device_binary?
            RunLoop::Ipa.new(path)
          else
            nil
          end
        end.call
      end

      def run_loop_app
        @run_loop_app ||= lambda do
          if simulator_bundle?
            RunLoop::App.new(path)
          else
            nil
          end
        end.call
      end

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
