module Calabash
  module LifeCycle
    def start_app(path_or_application = nil, **opt)
      path_or_application ||= Application.default

      unless path_or_application
        raise 'No application given, and Application.default is not set'
      end

      Device.default.start_app(path_or_application, opt.dup)
    end

    def stop_app
      Device.default.stop_app
    end

    # Installs the given application. If the application is already installed,
    # the application will be uninstalled, and installed afterwards. If no
    # application is given, it will install `Application.default`.
    #
    # If the given application is an instance of
    # `Calabash::Android::Application`, the same procedure is executed for the
    # test-server of the application, if it is set.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of `Calabash::Application`. Defaults to
    #  `Application.default`
    def install_app(path_or_application = nil)
      path_or_application ||= Application.default

      unless path_or_application
        raise 'No application given, and Application.default is not set'
      end

      Device.default.install_app(path_or_application)
    end

    # Installs the given application *if it is not already installed*. If no
    # application is given, it will ensure `Application.default` is installed.
    # If the application has changed, it will be installed using the same
    # approach as #{Calabash::LifeCycle#install_app}.
    #
    # If the given application is an instance of
    # `Calabash::Android::Application`, the same procedure is executed for the
    # test-server of the application, if it is set.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of `Calabash::Application`. Defaults to
    #  `Application.default`
    def ensure_app_installed(path_or_application = nil)
      path_or_application ||= Application.default

      unless path_or_application
        raise 'No application given, and Application.default is not set'
      end

      Device.default.ensure_app_installed(path_or_application)
    end

    # Uninstalls the given application. Does nothing if the application is
    # already uninstalled. If no application is given, it will uninstall
    # `Application.default`.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of `Calabash::Application`. Defaults to
    #  `Application.default`
    def uninstall_app(path_or_application = nil)
      path_or_application ||= Application.default

      unless path_or_application
        raise 'No application given, and Application.default is not set'
      end

      Device.default.uninstall_app(path_or_application)
    end

    # Clears the contents of the given application. This is roughly equivalent to
    # reinstalling the application. If no  application is given, it will clear
    # `Application.default`.
    #
    # @param [String, Calabash::Application] path_or_application A path to the
    #  application, or an instance of `Calabash::Application`. Defaults to
    #  `Application.default`
    def clear_app_data(path_or_application = nil)
      path_or_application ||= Application.default

      unless path_or_application
        raise 'No application given, and Application.default is not set'
      end

      Device.default.clear_app_data(path_or_application)
    end

    # Sends the current app to the background and resumes it after
    # `for_seconds`. This should not exceed 60 seconds for iOS.
    #
    # On Android you can control the app lifecycle more granularly using
    # #{Calabash::Android::Interactions#go_home} and
    # #{Calabash::Android::LifeCycle#resume_app}.
    def send_current_app_to_background(for_seconds = 10)
      _send_current_app_to_background(for_seconds)

      true
    end

    # @!visibility private
    def _send_current_app_to_background(for_seconds)
      abstract_method!
    end
  end
end
