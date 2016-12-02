module Calabash
  module Android
    # Android specific life cycle methods.
    module LifeCycle
      # Resume an application. If the application is already focused, nothing
      # will happen.
      #
      # @example
      #  go_home
      #  # Do something
      #  resume_app
      def resume_app
        Calabash::Internal.with_current_target(required_os: :android) {|target| target.resume_app}

        true
      end

      # @!visibility private
      define_method(:_send_current_app_to_background) do |for_seconds|
        package = focused_package
        activity = focused_activity

        go_home
        sleep(for_seconds)
        Calabash::Internal.with_current_target(required_os: :android) {|target| target.resume_activity(package, activity)}
      end
    end
  end
end
