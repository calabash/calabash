module Calabash
  module Build
    module AndroidTestServer
      require File.join(__dir__, '..', 'lib', 'calabash', 'environment')
      require File.join(__dir__, '..', 'lib', 'calabash', 'android', 'environment')
      require File.join(__dir__, '..', 'lib', 'calabash', 'logger')

      module Messages
        TEST_SERVER_NOT_FOUND = 'The test-server was not found'
        CALABASH_JS_NOT_FOUND = 'calabash-js not found'
        BUILD_FAILED = 'Could not build the test server. Please see the output above.'
        SEE_INSTRUCTIONS = 'For instructions on building Calabash see: https://github.com/calabash/calabash/'
      end

      def self.ensure_test_server_exists
        fail(-1, Messages::TEST_SERVER_NOT_FOUND) unless File.exists?(test_server_directory)
      end

      def self.ensure_calabash_js_exists
        fail(-1, Messages::CALABASH_JS_NOT_FOUND) unless File.exists?(calabash_js_directory)
      end

      def self.build_test_server
        FileUtils.cp(File.join(test_server_directory, 'AndroidManifest.xml'), android_manifest_location)

        Dir.mktmpdir do |workspace_dir|
          test_server_dir = File.join(workspace_dir, 'server')
          FileUtils.cp_r(test_server_directory, workspace_dir)

          args =
            [
              Android::Environment.ant_path,
              "clean",
              "package",
              "-debug",
              "-Dtools.dir=\"#{Android::Environment.tools_directory}\"",
              "-Dandroid.api.level=19",
              "-Dversion=#{Calabash::VERSION}"
            ]

          Dir.chdir(test_server_dir) do
            STDOUT.sync = true

            IO.popen(args.join(' ')) do |io|
              io.each {|s| print s}
            end

            fail($?.exitstatus, Messages::BUILD_FAILED) if $?.exitstatus != 0
          end

          FileUtils.mkdir_p('test_servers') unless File.exist?('test_servers')

          FileUtils.cp(File.join(test_server_dir, 'bin', 'Test_unsigned.apk'), test_server_location)
        end
      end

      private

      def self.test_server_directory
        File.join(find_server_repo_or_raise, 'server')
      end

      def self.calabash_js_directory
        File.join(test_server_directory, 'calabash-js')
      end

      def self.test_server_location
        File.join(ROOT, 'lib', 'calabash', 'android', 'lib', 'TestServer.apk')
      end

      def self.android_manifest_location
        File.join(ROOT, 'lib', 'calabash', 'android', 'lib', 'AndroidManifest.xml')
      end

      def self.fail(exit_code, reason = '')
        puts reason unless reason.empty?
        puts Messages::SEE_INSTRUCTIONS
        exit(exit_code)
      end

      def self.find_server_repo_or_raise
        calabash_server_dir = ENV['CALABASH_SERVER_PATH'] || File.join(File.dirname(__FILE__), '..', '..', 'calabash-android-server')
        unless File.exist?(calabash_server_dir) && File.exists?(File.join(calabash_server_dir, "server", "calabash-js", "src"))
          raise %Q{\033[31m
Expected to find the calabash-android-server repo at:

    #{File.expand_path(calabash_server_dir)}

Either clone the repo to that location with:

$ git clone --recursive git@github.com:calabash/calabash-android-server.git #{calabash_server_dir}

or set CALABASH_SERVER_PATH to point to your local copy of the server.

$ CALABASH_SERVER_PATH=/path/to/server bundle exec rake build

For full instuctions see: https://github.com/calabash/calabash-android/wiki/Building-calabash-android\033[0m

    }
        end

        calabash_server_dir
      end
    end
  end
end
