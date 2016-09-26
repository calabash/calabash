module Calabash

  # Methods for managing an app's life cycle.
  #
  # The life cycle of an app includes:
  #  * installing / uninstalling
  #  * stopping / starting
  #  * clearing the application data
  #  * sending the application to background and resuming it
  module LifeCycle
    # Start the given application (and its test-server) on the port of
    # {Calabash::Defaults#default_server Calabash.default_server}.
    # This method will **not** install the application specified. If no
    # application is given, it will start
    # {Calabash::Defaults#default_application Calabash.default_application}
    #
    # @note This method will fail if the application (and test-server for
    #  Android) is not installed, or if the application installed is not the
    #  same as the one specified.
    #
    # @note On Android, if a test-server is already running on the port of
    #  {Calabash::Defaults#default_server Calabash.default_server} then that
    #  application will be shut down.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of {Calabash::Application}.
    #  Defaults to
    #  {Calabash::Defaults#default_application Calabash.default_application}
    # @param [Hash] options Options for specifying the details the app start
    # @option options [Hash] :activity Android-only. Specify which activity
    #  to start. If none is given, launch the default launchable activity.
    # @option options [Hash] :extras Android-only. Specify the extras for the
    #  startup intent.
    def start_app(path_or_application = nil, **options)
      path_or_application ||= Calabash.default_application

      unless path_or_application
        raise 'No application given, and Calabash.default_application is not set'
      end

      Device.default.start_app(path_or_application, options.dup)
    end

    # Stop the app running on
    # {Calabash::Defaults#default_server Calabash.default_server}
    def stop_app
      Device.default.stop_app
    end

    # Installs the given application. If the application is already installed,
    # the application will be uninstalled, and installed afterwards. If no
    # application is given, it will install
    # {Calabash::Defaults#default_application Calabash.default_application}
    #
    # If the given application is an instance of
    # {Calabash::Android::Application}, the same procedure is executed for the
    # test-server of the application, if it is set.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of {Calabash::Application}.
    #  Defaults to
    #  {Calabash::Defaults#default_application Calabash.default_application}
    def install_app(path_or_application = nil)
      path_or_application ||= Calabash.default_application

      unless path_or_application
        raise 'No application given, and Calabash.default_application is not set'
      end

      Device.default.install_app(path_or_application)
    end

    # Installs the given application *if it is not already installed*. If no
    # application is given, it will ensure `Calabash.default_application` is installed.
    # If the application has changed, it will be installed using the same
    # approach as {#install_app}.
    #
    # If the given application is an instance of
    # {Calabash::Android::Application}, the same procedure is executed for the
    # test-server of the application, if it is set.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of {Calabash::Application}.
    #  Defaults to
    #  {Calabash::Defaults#default_application Calabash.default_application}
    def ensure_app_installed(path_or_application = nil)
      path_or_application ||= Calabash.default_application

      unless path_or_application
        raise 'No application given, and Calabash.default_application is not set'
      end

      Device.default.ensure_app_installed(path_or_application)
    end

    # Uninstalls the given application. Does nothing if the application is
    # already uninstalled. If no application is given, it will uninstall
    # {Calabash::Defaults#default_application Calabash.default_application}
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of {Calabash::Application}.
    #  Defaults to
    #  {Calabash::Defaults#default_application Calabash.default_application}
    def uninstall_app(path_or_application = nil)
      path_or_application ||= Calabash.default_application

      unless path_or_application
        raise 'No application given, and Calabash.default_application is not set'
      end

      Device.default.uninstall_app(path_or_application)
    end

    # Clears the contents of the given application. This is roughly equivalent to
    # reinstalling the application. If no  application is given, it will clear
    # {Calabash::Defaults#default_application Calabash.default_application}.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of {Calabash::Application}.
    #  Defaults to
    #  {Calabash::Defaults#default_application Calabash.default_application}
    def clear_app_data(path_or_application = nil)
      path_or_application ||= Calabash.default_application

      unless path_or_application
        raise 'No application given, and Calabash.default_application is not set'
      end

      Device.default.clear_app_data(path_or_application)
    end

    # Sends the current app to the background and resumes it after
    # `for_seconds`.
    #
    # On iOS, `for_seconds` must be between 1 and 60 seconds.
    #
    # On iOS the _current app_ is the app under test (your app).
    #
    # On Android you can control the app lifecycle more granularity using
    # {Calabash::Android::Interactions#go_home \#go_home} and
    # {Calabash::Android::LifeCycle#resume_app \#resume_app}.
    #
    # @param [Numeric] for_seconds How long to keep the app to the background.
    #
    # @raise [ArgumentError] On iOS, if number of seconds is less than 1 and
    # more than 60 seconds.
    def send_current_app_to_background(for_seconds = 10)
      _send_current_app_to_background(for_seconds)

      true
    end

    # @!visibility private
    define_method(:_send_current_app_to_background) do |for_seconds|
      abstract_method!(:_send_current_app_to_background)
    end
  end
end
