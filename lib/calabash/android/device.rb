module Calabash
  module Android
    class Device < Calabash::Android::Operations::Device
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

      def installed_apps
        adb('shell pm list packages').lines.map do |line|
          {id: line.sub('package:', '').chomp}
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
    end
  end
end
