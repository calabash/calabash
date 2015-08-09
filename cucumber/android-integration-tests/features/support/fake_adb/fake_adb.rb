#!/usr/bin/env ruby


$log = File.open('MY_LOG2.txt', 'w')
$log.sync = true
$log.write("StART\n")

begin

  unless $cucumber
  $log.write("NOT CUCUMBER\n")
  $log.write("#{ARGV}\n")

require 'fileutils'

module Calabash
  module Test
    COMMAND_NAME = File.join(File.dirname(__FILE__), "adb-command")
    IN_NAME = File.join(File.dirname(__FILE__), "adb-in")
    OUT_NAME = File.join(File.dirname(__FILE__), "adb-out")
    ERR_NAME = File.join(File.dirname(__FILE__), "adb-err")
    EXIT_CODE_NAME = File.join(File.dirname(__FILE__), "adb-exit-code")
    EXECUTE_NAME = File.join(File.dirname(__FILE__), 'execute')
    DONE_EXECUTING_NAME = File.join(File.dirname(__FILE__), 'done-executing')
    PID_FILE_NAME = File.join(File.dirname(__FILE__), 'pid')

    def self.start_adb
      File.delete(COMMAND_NAME) if File.exist?(COMMAND_NAME)
      File.delete(IN_NAME) if File.exist?(IN_NAME)
      File.delete(OUT_NAME) if File.exist?(OUT_NAME)
      File.delete(ERR_NAME) if File.exist?(ERR_NAME)
      File.delete(EXIT_CODE_NAME) if File.exist?(EXIT_CODE_NAME)
      File.delete(EXECUTE_NAME) if File.exist?(EXECUTE_NAME)
      File.delete(DONE_EXECUTING_NAME) if File.exist?(DONE_EXECUTING_NAME)
      File.delete(PID_FILE_NAME) if File.exist?(PID_FILE_NAME)

      $log.write "SPAWNING PROCESS\n"

      pid = Process.spawn(File.join(File.dirname(__FILE__), 'fake_adb_d.rb'))

      $log.write "ABOUT TO DETACH\n"
      Process.detach(pid)

      File.open(PID_FILE_NAME, 'w') do |file|
        file.write(pid)
      end

      $log.write "PID: #{pid}\n"
      $log.write "DONE WRITING PID\n"
    end

    def self.stop_adb
      File.open(COMMAND_NAME, 'w+') do |file|
        file.write("KILL\n")
      end

      pid = nil

      File.open(PID_FILE_NAME, 'r') do |file|
        pid = file.read.to_i
      end

      $log.write("Killing '#{pid}'\n")

      Process.kill(9, pid)

      File.delete(PID_FILE_NAME) if File.exist?(PID_FILE_NAME)
      File.delete(COMMAND_NAME) if File.exist?(COMMAND_NAME)
      File.delete(IN_NAME) if File.exist?(IN_NAME)
      File.delete(OUT_NAME) if File.exist?(OUT_NAME)
      File.delete(ERR_NAME) if File.exist?(ERR_NAME)
      File.delete(EXIT_CODE_NAME) if File.exist?(EXIT_CODE_NAME)
      File.delete(EXECUTE_NAME) if File.exist?(EXECUTE_NAME)
      File.delete(DONE_EXECUTING_NAME) if File.exist?(DONE_EXECUTING_NAME)
    end

    def self.contact_adb(input)
      $log.write("CONTACT #{input}\n")
      File.delete(COMMAND_NAME) if File.exist?(COMMAND_NAME)
      File.delete(EXIT_CODE_NAME) if File.exist?(EXIT_CODE_NAME)
      File.delete(COMMAND_NME) if File.exist?(COMMAND_NAME)
      File.delete(DONE_EXECUTING_NAME) if File.exist?(DONE_EXECUTING_NAME)
      File.delete(IN_NAME) if File.exist?(IN_NAME)

      File.open(COMMAND_NAME, 'w+') do |file|
        input.each do |cmd|
          file.write("#{cmd}\n")
        end
      end

      File.open(IN_NAME, 'w+') do |file|
        if !$stdin.tty? && $stdin.stat.size > 0
          $log.write("ABOUT TO READ")
          while (line = $stdin.gets)
            $log.write("READ #{line}")
            file.write(line)
          end
          $log.write("DONE READING")
        end
      end

      FileUtils.touch(EXECUTE_NAME)

      $log.write("WAITING FOR DONE EXECUTING\n")

      until File.exist?(DONE_EXECUTING_NAME)
      end
      $log.write("DONE WAITING FOR DONE EXECUTING\n")

      File.delete(DONE_EXECUTING_NAME)

      m = nil

      File.readlines(OUT_NAME).each do |line|
        $log.write ("READ LINE #{line}\n")
        if line.start_with?('OUT:')
          m = $stdout
          line = line[4..-1]
        elsif line.start_with?('ERR:')
          m = $stderr
          line = line[4..-1]
        end
        $log.write ("NEW LINE #{line}\n")

        m.write(line)
        m.flush
      end

      #$stdout.write File.read(OUT_NAME)
      #$stderr.write File.read(ERR_NAME)

      #File.delete(OUT_NAME)
      #File.delete(ERR_NAME)

      exit_code = File.read(EXIT_CODE_NAME).to_i

      if exit_code == 136
        raise Exception, "ADB HAS BEEN KILLED"
      end

      exit exit_code
    end
  end
end

if ARGV[0] == 'ADB-START'
  Calabash::Test.start_adb
elsif ARGV[0] == 'ADB-STOP'
  Calabash::Test.stop_adb
elsif ARGV[0] == 'TEST'
  $log.write("TEST\n")
  $log.write "SPAWNING PROCESS\n"

  pid = fork do
    exec File.join(File.dirname(__FILE__), 'fake_adb_d.rb')
  end
  $log.write "ABOUT TO DETACH\n"
  Process.detach(pid)
  Process.daemon

else
  Calabash::Test.contact_adb(ARGV)
end


$log.write("HERE\n")
end
ensure
  $log.write("HERE2\n")
  $log.close if $log && !$log.closed?
end

