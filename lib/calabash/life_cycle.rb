module Calabash

  # Methods for managing an app's life cycle.
  #
  # The life cycle of an app includes:
  #  * installing / uninstalling
  #  * stopping / starting
  #  * clearing the application data
  #  * sending the application to background and resuming it
  module LifeCycle
    # Start the current target's application (and its test-server) on the port
    # set by the current target.
    #
    # @note This method will **not** install the application specified.
    #
    # @note This method will fail if the application (and test-server for
    #  Android) is not installed, or if the application installed is not the
    #  same as the one specified.
    #
    # @note On Android, if a test-server is already running on the port of
    #  the current target then that application will be shut down.
    #
    # @param [Hash] options Options for specifying the details the app start
    # @option options [Hash] :activity Android-only. Specify which activity
    #  to start. If none is given, launch the default launchable activity.
    # @option options [Hash] :extras Android-only. Specify the extras for the
    #  startup intent.
    def start_app(**options)
      Calabash::Internal.with_current_target {|target| target.start_app(options.dup)}
    end

    # Stop the current target's application.
    def stop_app
      Calabash::Internal.with_current_target {|target| target.stop_app}
    end

    # Installs the current target's application. If the application is already
    # installed, the application will be uninstalled, and installed afterwards.
    #
    # If the given application is an instance of
    # {Calabash::Android::Application}, the same procedure is executed for the
    # test-server of the application, if it is set.
    def install_app
      Calabash::Internal.with_current_target {|target| target.install_app}
    end

    # Installs the current target's application *if it is not already
    # installed*.
    #
    # If the application has changed, it will be installed using the same
    # approach as {#install_app}.
    #
    # If the given application is an instance of
    # {Calabash::Android::Application}, the same procedure is executed for the
    # test-server of the application, if it is set.
    def ensure_app_installed
      Calabash::Internal.with_current_target {|target| target.ensure_app_installed}
    end

    # Uninstalls the current target's application. Does nothing if the
    # application is already uninstalled.
    def uninstall_app
      Calabash::Internal.with_current_target {|target| target.uninstall_app}
    end

    # Clears the contents of the current target's application. This is roughly
    # equivalent to reinstalling the application.
    #
    # If the application is not installed (or the test-server on Android), then
    # this method will fail.
    #
    # @example
    #  # Clear the application data if we have not tagged our Cucumber scenario
    #  # with no_reset
    #  Before('~@no_reset) do
    #   ensure_app_installed
    #   clear_app_data
    #  end
    #
    # @raise [RuntimeError] if the application is not installed.
    def clear_app_data
      Calabash::Internal.with_current_target {|target| target.clear_app_data}
    end

    # Sends the current target's application to the background and resumes it
    # after `for_seconds`.
    #
    # On Android you can control the app lifecycle more granularity using
    # {Calabash::Android::Interactions#go_home cal_android.go_home} and
    # {Calabash::Android::LifeCycle#resume_app cal_android.resume_app}.
    #
    # @param [Numeric] for_seconds How long to keep the app to the background.
    def send_current_app_to_background(for_seconds = 10)
      _send_current_app_to_background(for_seconds)

      true
    end

    # Attempts to reset the changes Calabash has made to the device.
    #
    # This method does nothing at the moment, but will be required to reset the
    # device changes in the future.
    def reset_device_changes
      true
    end

    # @!visibility private
    define_method(:_send_current_app_to_background) do |for_seconds|
      abstract_method!(:_send_current_app_to_background)
    end
  end
end
