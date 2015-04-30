module Calabash
  module Android
    class Device < Calabash::Android::Operations::Device
      def self.default_serial
        serials = list_serials

        if serials.length == 0
          raise 'No devices visible on adb. Ensure a device is visible in `adb devices`'
        end

        if serials.length > 1
          raise 'More than one device connected. Use $CAL_IDENTIFIER to select serial'
        end

        serials.first
      end

      def self.list_serials
        output = ADB.command('devices')
        lines = output.lines
        index = lines.index{|line| line.start_with?('List of devices attached')}

        if index.nil?
          raise "Could not parse adb output: '#{lines}'"
        end

        device_lines = lines[(index+1)..-1].select{|line| line.strip != ''}

        device_lines.collect do |line|
          line.match(/([^\s]+)/).captures.first
        end
      end

      def adb(command)
        ADB.command(command, identifier)
      end

      def installed_packages
        adb('shell pm list packages').lines.map do |line|
          line.sub('package:', '').chomp
        end
      end

      def test_server_responding?
        begin
          http_client.get(HTTP::Request.new('ping')).body == 'pong'
        rescue HTTP::Error => _
          false
        end
      end

      private

      # @!visibility private
      def _screenshot(path)
        cmd = "java -jar \"#{Screenshot::SCREENSHOT_JAR_PATH}\" #{identifier} \"#{File.expand_path(path)}\""

        @logger.log "Taking screenshot using '#{cmd}'"
        raise 'Could not take screenshot' unless system(cmd)

        @logger.log("Saved screenshot as #{File.expand_path(path)}", :info)
        path
      end

      # @!visibility private
      def _clear_app(identifier)
        adb("shell pm clear #{identifier}")
      end

      # @!visibility private
      def _install(application)
        @logger.log "Installing #{application.path}"
        result = adb("install -r #{application.path}").lines.last

        if result.downcase.chomp != 'success'
          raise "Could not install app: #{result}"
        end

        unless installed_packages.include?(application.identifier)
          raise 'App was not installed'
        end

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log "Installing the test-server as well"
            install(application.test_server)
          end
        end
      end

      # @!visibility private
      def _uninstall(package)
        @logger.log "Uninstalling #{package}"
        result = adb("uninstall #{package}").lines.last

        if result.downcase.chomp != 'success'
          raise "Could not uninstall app: #{result}"
        end

        if installed_packages.include?(package)
          raise 'App was not uninstalled'
        end
      end

      # @!visibility private
      def _port_forward(host_port)
        adb_forward_cmd = "forward tcp:#{host_port} tcp:#{server.test_server_port}"
        ADB.command(adb_forward_cmd)
      end
    end
  end
end
