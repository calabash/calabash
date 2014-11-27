module Calabash
  module Build
    module AndroidTestServer
      module Messages
        CALABASH_JS_NOT_FOUND = 'calabash-js not found'
        SEE_INSTRUCTIONS = 'For instructions on building Calabash see: https://github.com/calabash/calabash/'
      end

      def self.ensure_calabash_js_exists
        unless File.exists?(calabash_js_directory)
          fail(1, Messages::CALABASH_JS_NOT_FOUND)
        end
      end

      private

      def self.calabash_js_directory
        File.join(ROOT, 'android', 'test-server', 'calabash-js')
      end

      def self.fail(exit_code, reason = '')
        puts reason unless reason.empty?
        puts Messages::SEE_INSTRUCTIONS
        exit(exit_code)
      end
    end
  end
end
