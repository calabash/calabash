 require 'fileutils'
 class Calabash::IOS::Device

   def app_installed_on_physical_device?(application, device_udid)
     out = `/usr/local/bin/ideviceinstaller --udid #{device_udid} --list-apps`
     out.split(/\s/).include? application.identifier
   end

   def install_app_on_physical_device(application, device_udid)

     if app_installed_on_physical_device?(application, device_udid)
       uninstall_app_on_physical_device(application, device_udid)
     end

     args =
           [
                 '--udid', device_udid,
                 '--install', application.path
           ]

     log = FileUtils.touch('./ideviceinstaller.log')
     system('/usr/local/bin/ideviceinstaller', *args, {:out => log})

     exit_code = $?
     unless exit_code == 0
       raise "Could not install the app (#{exit_code}).  See #{File.expand_path(log)}"
     end
     true
   end

   def uninstall_app_on_physical_device(application, device_udid)

     if app_installed_on_physical_device?(application, device_udid)

       args =
             [
                   '--udid', device_udid,
                   '--uninstall', application.identifier
             ]

       log = FileUtils.touch('./ideviceinstaller.log')
       system('/usr/local/bin/ideviceinstaller', *args, {:out => log})

       exit_code = $?
       unless exit_code == 0
         raise "Could not uninstall the app (#{exit_code}).  See #{File.expand_path(log)}"
       end
     end
     true
   end

   def ensure_app_installed_on_physical_device(application, device_udid)
     unless app_installed_on_physical_device?(application, device_udid)
       install_app_on_physical_device(application, device_udid)
     end
     true
   end

   # The only way to clear the data is to uninstall the app.
   def clear_app_data_on_physical_device(application, device_udid)
     if app_installed_on_physical_device?(application, device_udid)
       install_app_on_physical_device(application, device_udid)
     end
     true
   end
 end
