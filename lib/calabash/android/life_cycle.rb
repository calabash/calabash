module Calabash
  module Android
    module LifeCycle
      # Resume an application. If the application is already focused, nothing
      # will happen.
      #
      # @example
      #  go_home
      #  resume_app
      #
      # @param [String, Calabash::Application] path_or_application The
      #  application to resume.
      def resume_app(path_or_application = nil)
        path_or_application ||= Application.default

        unless path_or_application
          raise 'No application given, and Application.default is not set'
        end

        Device.default.resume_app(path_or_application)

        true
      end


      # !@visibility private
      def _send_current_app_to_background(for_seconds)
        package = focused_package
        activity = focused_activity

        go_home
        sleep(for_seconds)
        Device.default.resume_activity(package, activity)
      end
    end
  end
end