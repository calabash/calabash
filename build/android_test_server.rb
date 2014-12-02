module Calabash
  module Build
    module AndroidTestServer
      # TODO: These requirements should be specified elsewhere
      require 'calabash/logger'
      require 'calabash/environment'
      require 'calabash/android/environment'

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
        Dir.mktmpdir do |workspace_dir|
          test_server_dir = File.join(workspace_dir, 'test-server')
          FileUtils.cp_r(test_server_directory, workspace_dir)

          args =
            [
              Calabash::Android::Environment.ant_path,
              "clean",
              "package",
              "-debug",
              "-Dtools.dir=\"#{Calabash::Android::Environment.tools_dir}\"",
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
        File.join(ROOT, 'android', 'test-server')
      end

      def self.calabash_js_directory
        File.join(test_server_directory, 'calabash-js')
      end

      def self.test_server_location
        File.join(ROOT, 'lib', 'calabash', 'android', 'lib', 'TestServer.apk')
      end

      def self.fail(exit_code, reason = '')
        puts reason unless reason.empty?
        puts Messages::SEE_INSTRUCTIONS
        exit(exit_code)
      end
    end
  end
end
