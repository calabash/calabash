module Calabash
  module Android
    # Android specific life cyle methods.
    module LifeCycle
      # Resume an application. If the application is already focused, nothing
      # will happen.
      #
      # @example
      #  go_home
      #  # Do something
      #  resume_app
      #
      # @param [String, Calabash::Application] path_or_application A path to the
      #  application, or an instance of {Calabash::Application}.
      #  Defaults to
      #  {Calabash::Defaults#default_application Calabash.default_application}
      def resume_app(path_or_application = nil)
        path_or_application ||= Application.default

        unless path_or_application
          raise 'No application given, and Application.default is not set'
        end

        Calabash::Internal.with_current_target(required_os: :android) {|target| target.resume_app(path_or_application)}

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
