module Calabash
  module IOS

    # A mixin for IOS::Device that provides methods that users can override
    # to use a third-party tool like `ideviceinstaller` or `ios-deploy` to
    # manage apps on physical devices.
    #
    #
    # Calabash cannot manage apps on physical devices.  There are third-party
    # tools you can use to manage apps on devices.  Two popular tools are
    # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
    #
    # To integrate these tools, Calabash provides several methods for you to
    # override in your project.  In your `features/support/` directory, you
    # can patch Calabash::IOS::Device with your own implementation of these
    # methods.  The five methods to override are:
    #
    # 1. app_installed_on_physical_device?
    # 2. install_app_on_physical_device
    # 3. ensure_app_installed_on_physical_device
    # 4. clear_app_data_on_physical_device
    # 5. uninstall_app_on_physical_device
    #
    #
    # ```
    #  # features/support/ideviceinstaller.rb
    #
    #  require 'fileutils'
    #  class Calabash::IOS::Device
    #
    #    def app_installed_on_physical_device?(application, device_udid)
    #      out = `/usr/local/bin/ideviceinstaller --udid #{device_udid} --list-apps`
    #      out.split(/\s/).include? application.identifier
    #    end
    #
    #    def install_app_on_physical_device(application, device_udid)
    #
    #      if app_installed_on_physical_device?(application, device_udid)
    #        uninstall_app_on_physical_device(application, device_udid)
    #      end
    #
    #      args =
    #            [
    #                  '--udid', device_udid,
    #                  '--install', application.path
    #            ]
    #
    #      log = FileUtils.touch('./ideviceinstaller.log')
    #      system('/usr/local/bin/ideviceinstaller', *args, {:out => log})
    #
    #      exit_code = $?
    #      unless exit_code == 0
    #        raise "Could not install the app (#{exit_code}).  See #{File.expand_path(log)}"
    #      end
    #      true
    #    end
    #
    #    def uninstall_app_on_physical_device(application, device_udid)
    #
    #      if app_installed_on_physical_device?(application, device_udid)
    #
    #        args =
    #              [
    #                    '--udid', device_udid,
    #                    '--uninstall', application.identifier
    #              ]
    #
    #        log = FileUtils.touch('./ideviceinstaller.log')
    #        system('/usr/local/bin/ideviceinstaller', *args, {:out => log})
    #
    #        exit_code = $?
    #        unless exit_code == 0
    #          raise "Could not uninstall the app (#{exit_code}).  See #{File.expand_path(log)}"
    #        end
    #      end
    #      true
    #    end
    #
    #    def ensure_app_installed_on_physical_device(application, device_udid)
    #      unless app_installed_on_physical_device?(application, device_udid)
    #        install_app_on_physical_device(application, device_udid)
    #      end
    #      true
    #    end
    #
    #    # The only way to clear the data is to uninstall the app.
    #    def clear_app_data_on_physical_device(application, device_udid)
    #      if app_installed_on_physical_device?(application, device_udid)
    #        install_app_on_physical_device(application, device_udid)
    #      end
    #      true
    #    end
    #  end
    # ```
    #
    # For a real-world example of a ruby wrapper around the ideviceinstaller
    # command-line tool, see https://github.com/calabash/ios-smoke-test-app.
    #
    # @see #app_installed_on_physical_device?
    # @see #install_app_on_physical_device
    # @see #ensure_app_installed_on_physical_device
    # @see #clear_app_data_on_physical_device
    # @see #uninstall_app_on_physical_device
    #
    # @see http://brew.sh/
    # @see https://github.com/libimobiledevice/ideviceinstaller
    # @see https://github.com/phonegap/ios-deploy
    # @see https://github.com/calabash/ios-smoke-test-app/blob/master/CalSmokeApp/features/support/ideviceinstaller.rb
    # @see https://github.com/blueboxsecurity/idevice
    #
    # For an real-world example of a ruby wrapper around the ideviceinstaller
    # tool, see /blob/master/CalSmokeApp/features/support/ideviceinstaller.rb
    module PhysicalDeviceMixin

      # Install an app on physical device.  To fit into Calabash's app lifecycle
      # model, implementations of this method must follow these rules:
      #
      # 1. If the app is installed, uninstall it, and then install it.
      # 2. If the app cannot be uninstalled or installed, raise a StandardError.
      #
      # param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] If the app was installed ont the device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def install_app_on_physical_device(application, device_udid)
        logger.log('To install an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #install_app_on_physical_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device install_app_on_physical_device must be implemented by you.'
      end

      # Ensures that `application` is installed on a physical device.  To fit
      # into Calabash's app lifecycle model, implementations of this method must
      # follow these rules:
      #
      # 1. If the app is not installed, install it.
      # 2. If the app is installed, return true
      # 3. If the app cannot be installed, raise a StandardError.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] If the app is installed on the physical_device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def ensure_app_installed_on_physical_device(application, device_udid)
        logger.log('To check if an app installed on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #ensure_app_installed_on_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device ensure_app_installed_on_device must be implemented by you.'
      end

      # Clears the application's data from a physical device.  To fit into
      # Calabash's app lifecycle model, implementations of this method must
      # follow these rules:
      #
      # 1. The data in the applications sandbox must be reset to a good known
      #    state.  What that means for your application is up to you to
      #    decide.  Generally, this means you should remove _all_ files from
      #    the application's sandbox.
      # 2. If the data has been reset, return true.
      # 3. If the app data cannot be cleared, raise a StandardError.
      #
      # Some kinds of user data are very difficult to clear.  For example,
      # values stored in NSUserDefaults are not removed when an app is
      # uninstalled.  The same is true for values stored in the Keychain.
      #
      # You might need to add logic in your Cucumber Before hooks to clear
      # such data.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application data was cleared.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def clear_app_data_on_physical_device(application, device_udid)
        logger.log('To clear app data on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #clear_app_data_on_physical_device', :info)
        logger.log('method using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device clear_app_data_on_physical_device must be implemented by you.'
      end

      # Returns true if the application is installed on a physical device. To
      # fit into Calabash's app lifecycle model, implementations of this method
      # must follow these rules:
      #
      # 1. If the app is installed, this method must return true.
      # 2. If the app is not installed, this method must return false.
      # 3. If the state of the app on the device cannot be determined, raise
      #    a RuntimeError.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application is installed on the
      #  device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def app_installed_on_physical_device?(application, device_udid)
        logger.log('To determine if an app is installed on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #app_installed_on_physical_device', :info)
        logger.log('method using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device app_installed_on_physical_device? must be implemented by you.'
      end

      # Uninstalls an application from a physical device. To fit into Calabash's
      # app lifecycle model, implementations of this method must follow these
      # rules:
      #
      # 1. Return true if the app was uninstalled.
      # 2. Raise an error if the app cannot be uninstalled.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application was uninstalled.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def uninstall_app_on_physical_device(application, device_udid)
        logger.log('To uninstall an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #uninstall_app_on_physical_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device uninstall_app_on_physical_device must be implemented by you.'
      end
    end
  end
end
