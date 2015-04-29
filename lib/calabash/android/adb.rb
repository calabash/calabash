module Calabash
  module Android
    module ADB
      def self.command(command, serial=nil)
        full_command = if serial
                         "#{Environment.adb_path} -s #{serial} #{command}"
                       else
                         "#{Environment.adb_path} #{command}"
                       end

        Logger.debug("Executing: #{full_command}")
        `#{full_command}`
      end
    end
  end
end
