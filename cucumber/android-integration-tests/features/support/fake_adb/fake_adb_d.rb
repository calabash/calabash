#!/usr/bin/env ruby
begin
require 'fileutils'
$log = File.open('LOG2.txt', 'a+')
$log.write "CUCUMBER: #{$cucumber}"
unless $cucumber
  $log.sync = true
  $log.write "NOT CUCUMBER"

COMMAND_NAME = File.join(File.dirname(__FILE__), "adb-command")
IN_NAME = File.join(File.dirname(__FILE__), "adb-in")
OUT_NAME = File.join(File.dirname(__FILE__), "adb-out")
ERR_NAME = File.join(File.dirname(__FILE__), "adb-err")
EXIT_CODE_NAME = File.join(File.dirname(__FILE__), "adb-exit-code")
PID_FILE_NAME = File.join(File.dirname(__FILE__), 'pid')
EXECUTE_NAME = File.join(File.dirname(__FILE__), 'execute')
DONE_EXECUTING_NAME = File.join(File.dirname(__FILE__), 'done-executing')

failure_msg = <<eos
Android Debug Bridge version 1.0.31

 -a                            - directs adb to listen on all interfaces for a connection
 -d                            - directs command to the only connected USB device
                                 returns an error if more than one USB device is present.
 -e                            - directs command to the only running emulator.
                                 returns an error if more than one emulator is running.
 -s <specific device>          - directs command to the device or emulator with the given
                                 serial number or qualifier. Overrides ANDROID_SERIAL
                                 environment variable.
 -p <product name or path>     - simple product name like 'sooner', or
                                 a relative/absolute path to a product
                                 out directory like 'out/target/product/sooner'.
                                 If -p is not specified, the ANDROID_PRODUCT_OUT
                                 environment variable is used, which must
                                 be an absolute path.
 -H                            - Name of adb server host (default: localhost)
 -P                            - Port of adb server (default: 5037)
 devices [-l]                  - list all connected devices
                                 ('-l' will also list device qualifiers)
 connect <host>[:<port>]       - connect to a device via TCP/IP
                                 Port 5555 is used by default if no port number is specified.
 disconnect [<host>[:<port>]]  - disconnect from a TCP/IP device.
                                 Port 5555 is used by default if no port number is specified.
                                 Using this command with no additional arguments
                                 will disconnect from all connected TCP/IP devices.

device commands:
  adb push <local> <remote>    - copy file/dir to device
  adb pull <remote> [<local>]  - copy file/dir from device
  adb sync [ <directory> ]     - copy host->device only if changed
                                 (-l means list but don't copy)
                                 (see 'adb help all')
  adb shell                    - run remote shell interactively
  adb shell <command>          - run remote shell command
  adb emu <command>            - run emulator console command
  adb logcat [ <filter-spec> ] - View device log
  adb forward --list           - list all forward socket connections.
                                 the format is a list of lines with the following format:
                                    <serial> " " <local> " " <remote> "\n"
  adb forward <local> <remote> - forward socket connections
                                 forward specs are one of:
                                   tcp:<port>
                                   localabstract:<unix domain socket name>
                                   localreserved:<unix domain socket name>
                                   localfilesystem:<unix domain socket name>
                                   dev:<character device name>
                                   jdwp:<process pid> (remote only)
  adb forward --no-rebind <local> <remote>
                               - same as 'adb forward <local> <remote>' but fails
                                 if <local> is already forwarded
  adb forward --remove <local> - remove a specific forward socket connection
  adb forward --remove-all     - remove all forward socket connections
  adb jdwp                     - list PIDs of processes hosting a JDWP transport
  adb install [-l] [-r] [-s] [--algo <algorithm name> --key <hex-encoded key> --iv <hex-encoded iv>] <file>
                               - push this package file to the device and install it
                                 ('-l' means forward-lock the app)
                                 ('-r' means reinstall the app, keeping its data)
                                 ('-s' means install on SD card instead of internal storage)
                                 ('--algo', '--key', and '--iv' mean the file is encrypted already)
  adb uninstall [-k] <package> - remove this app package from the device
                                 ('-k' means keep the data and cache directories)
  adb bugreport                - return all information from the device
                                 that should be included in a bug report.

  adb backup [-f <file>] [-apk|-noapk] [-obb|-noobb] [-shared|-noshared] [-all] [-system|-nosystem] [<packages...>]
                               - write an archive of the device's data to <file>.
                                 If no -f option is supplied then the data is written
                                 to "backup.ab" in the current directory.
                                 (-apk|-noapk enable/disable backup of the .apks themselves
                                    in the archive; the default is noapk.)
                                 (-obb|-noobb enable/disable backup of any installed apk expansion
                                    (aka .obb) files associated with each application; the default
                                    is noobb.)
                                 (-shared|-noshared enable/disable backup of the device's
                                    shared storage / SD card contents; the default is noshared.)
                                 (-all means to back up all installed applications)
                                 (-system|-nosystem toggles whether -all automatically includes
                                    system applications; the default is to include system apps)
                                 (<packages...> is the list of applications to be backed up.  If
                                    the -all or -shared flags are passed, then the package
                                    list is optional.  Applications explicitly given on the
                                    command line will be included even if -nosystem would
                                    ordinarily cause them to be omitted.)

  adb restore <file>           - restore device contents from the <file> backup archive

  adb help                     - show this help message
  adb version                  - show version num

scripting:
  adb wait-for-device          - block until device is online
  adb start-server             - ensure that there is a server running
  adb kill-server              - kill the server if it is running
  adb get-state                - prints: offline | bootloader | device
  adb get-serialno             - prints: <serial-number>
  adb get-devpath              - prints: <device-path>
  adb status-window            - continuously print device status for a specified device
  adb remount                  - remounts the /system partition on the device read-write
  adb reboot [bootloader|recovery] - reboots the device, optionally into the bootloader or recovery program
  adb reboot-bootloader        - reboots the device into the bootloader
  adb root                     - restarts the adbd daemon with root permissions
  adb usb                      - restarts the adbd daemon listening on USB
  adb tcpip <port>             - restarts the adbd daemon listening on TCP on the specified port
networking:
  adb ppp <tty> [parameters]   - Run PPP over USB.
 Note: you should not automatically start a PPP connection.
 <tty> refers to the tty for PPP stream. Eg. dev:/dev/omap_csmi_tty1
 [parameters] - Eg. defaultroute debug dump local notty usepeerdns

adb sync notes: adb sync [ <directory> ]
  <localdir> can be interpreted in several ways:

  - If <directory> is not specified, both /system and /data partitions will be updated.

  - If it is "system" or "data", only the corresponding partition
    is updated.

environmental variables:
  ADB_TRACE                    - Print debug information. A comma separated list of the following values
                                 1 or all, adb, sockets, packets, rwx, usb, sync, sysdeps, transport, jdwp
  ANDROID_SERIAL               - The serial number to connect to. -s takes priority over this if given.
  ANDROID_LOG_TAGS             - When used with the logcat option, only these debug tags are printed.
eos

require File.expand_path(File.join(File.dirname(__FILE__), 'fake_device'))

$forwarded = {}

$log.write "STARING"

def finish(exit_code)
  $log.write "finishing..."
  File.open(EXIT_CODE_NAME, 'w+') {|file| file.write(exit_code)}
  $out.close unless $out.closed?
  $err.close unless $err.closed?
  FileUtils.touch(DONE_EXECUTING_NAME)
  $log.write "finished"
end

def out(string)
  $out.write("OUT:#{string}")
  $out.flush
end

def err(string)
  $out.write("ERR:#{string}")
  $out.flush
end

begin
  $log.write "STarting loop"
loop do
  $log.write "L Start\n"
  until File.exist?(EXECUTE_NAME)
  end
  $log.write "EXECUTE_NAME exists\n"

  File.delete(EXECUTE_NAME)
  
  args = File.readlines(COMMAND_NAME).map(&:chomp)

  File.delete(COMMAND_NAME) if File.exist?(COMMAND_NAME)
  File.delete(OUT_NAME) if File.exist?(OUT_NAME)
  File.delete(ERR_NAME) if File.exist?(ERR_NAME)
  File.delete(EXIT_CODE_NAME) if File.exist?(EXIT_CODE_NAME)

  $out = File.open(OUT_NAME, 'w+')
  $err = File.open(ERR_NAME, 'w+')

  $log.write "READ ARGS #{args}\n"


  if args[0] == 'KILL-DEVICES'
    Calabash::Test::FakeAndroidDevice.devices = []
    finish 0
    next
  elsif args[0] == 'ADD-DEVICE'
    Calabash::Test::FakeAndroidDevice.devices << Calabash::Test::FakeAndroidDevice.new(args[1])
    finish 0
    next
  elsif args[0] == 'KILL'
    finish 0
    exit 0
  elsif args[0] == 'PING'
    out 'ping'
    finish 0
    next
  elsif args[0] == '-s'
    device = Calabash::Test::FakeAndroidDevice.devices.find{|device| device.serial == args[1]}
    args.shift
    args.shift

    command = args.shift

    if command == 'shell'
      if args.empty?
        if device.nil?
          err "error: device not found\n"
          finish 1
          next
        end

        has_read_exit = false
        $log.write("READING FOM #{IN_NAME}")
        cmds = []

        File.readlines(IN_NAME).each do |input|
          $log.write("READ #{input}\n")

          cmds << input
        end

        $log.write("DONE READING FOM #{IN_NAME}\n")

        cmds.each do |cmd|
          out "#{cmd.chomp}\r\n"
        end

        cmds.each do |cmd|
          out "shell@fakedevice:/ $ #{cmd.chomp}\r\r\n"

          if cmd == "exit 0\n"
            has_read_exit = true
          else
            $log.write("EXECUTING #{cmd}\n")
            device.shell(cmd.chomp)
          end
        end


        unless has_read_exit
          $log.write("WARNING! I WILL NOT EXIT\n")
          while true

          end
        end

        finish 0
        next
      else
        raise "Invalid args #{args}"
      end
    elsif command == 'install'
      unless args.empty?
        if device.nil?
          err "error: device not found\n"
          finish 1
          next
        end

        app_file = args.last

        unless File.exist?(app_file)
          err "can't find '#{app_file}' to install"
          finish 1
          next
        end

        err "3358 KB/s (1005386 bytes in 0.292s)\n"
        device.push_file(app_file, {path: "/data/local/tmp/#{File.basename(app_file)}", package: File.basename(app_file)[0..-5]})
        device.shell("pm install #{args[0..-2].join(' ')} /data/local/tmp/#{File.basename(app_file)}")
        device.shell("rm /data/local/tmp/#{File.basename(app_file)}")
        finish 0
        next
      else
        raise "Invalid args #{args}"
      end
    elsif command == 'uninstall'
      unless args.empty?
        if device.nil?
          err "error: device not found\n"
          finish 1
          next
        end

        package = args.last

        device.shell("pm uninstall #{package}")
        finish 0
        next
      else
        raise "Invalid args #{args}"
      end
    elsif command == 'forward'
      if device.nil?
        err "error: device not found\n"
        finish 1
        next
      end

      $log.write("ARGS: #{args}\n")

      from = args[0].match(/tcp:(\d+)/).captures.first
      to = args[1].match(/tcp:(\d+)/).captures.first

      $forwarded[device.serial] ||= {}
      $forwarded[device.serial][from] = to
      finish 0
      next
    else
      err "#{failure_msg}\n"
      finish 1
      next
    end
  else
    command = args.shift

    if command == 'devices'
      if args.empty?
        out "List of devices attached\n"

        Calabash::Test::FakeAndroidDevice.devices.each do |device|
          out "#{device.serial}\t\t#{device.status}\n"
        end

        finish 0
        next
      else
        raise "Invalid args #{args}"
      end
    else
      err "#{failure_msg}\n"
      finish 1
      next
    end
  end
end
rescue Exception => e
  File.open('EXCEPTION1', 'w+') do |file|
    file.puts e.message
    file.puts e.backtrace.join("\n")
  end
  raise e
ensure
  $out.close if $out && !$out.closed?
  $err.close if $err && !$err.closed?
end

end
rescue Exception => e

  File.open('EXCEPTION2', 'w+') do |file|
    file.puts e.message
    file.puts e.backtrace.join("\n")
  end
  raise e
ensure
  $log.close if $log && !$log.closed?
end























