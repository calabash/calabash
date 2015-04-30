module Calabash
  module IOS
    module Operations
      def _calabash_start_app(application, options={})
        test_options = options.dup

        Calabash::Device.default.calabash_start_app(application, test_options)
      end

      def _calabash_stop_app(options={})
        Calabash::Device.default.calabash_stop_app(options)
      end
    end
  end
end