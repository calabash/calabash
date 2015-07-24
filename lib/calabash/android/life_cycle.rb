module Calabash
  module Android
    module LifeCycle
      def resume_app(path_or_application = nil)
        path_or_application ||= Application.default

        unless path_or_application
          raise 'No application given, and Application.default is not set'
        end

        Device.default.resume_app(path_or_application)
      end
    end
  end
end