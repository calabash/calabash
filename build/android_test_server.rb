module Calabash
  module Build
    module AndroidTestServer
      module Messages
        TEST_SERVER_NOT_FOUND = 'The test-server was not found'
        CALABASH_JS_NOT_FOUND = 'calabash-js not found'
        SEE_INSTRUCTIONS = 'For instructions on building Calabash see: https://github.com/calabash/calabash/'
      end

      def self.ensure_test_server_exists
        fail(-1, Messages::TEST_SERVER_NOT_FOUND) unless File.exists?(test_server_directory)
      end

      def self.ensure_calabash_js_exists
        fail(-1, Messages::CALABASH_JS_NOT_FOUND) unless File.exists?(calabash_js_directory)
      end

      private

      def self.test_server_directory
        File.join(ROOT, 'android', 'test-server')
      end

      def self.calabash_js_directory
        File.join(test_server_directory, 'calabash-js')
      end

      def self.fail(exit_code, reason = '')
        puts reason unless reason.empty?
        puts Messages::SEE_INSTRUCTIONS
        exit(exit_code)
      end
    end
  end
end
