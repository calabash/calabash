module Calabash
  module Android
    module Build
      class TestServer
        def initialize(application_path)
          @application_path = application_path
        end

        def path
          "test_servers/#{checksum(@application_path)}_#{VERSION}.apk"
        end

        private

        def checksum(file_path)
          require 'digest/md5'
          Digest::MD5.file(file_path).hexdigest
        end
      end
    end
  end
end