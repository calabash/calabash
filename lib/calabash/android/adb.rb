require 'timeout'
require 'open3'

module Calabash
  module Android
    class ADB
      class ADBCallError < StandardError
        attr_reader :stderr, :stdout

        def initialize(message, stderr=nil, stdout=nil)
          super(message)

          @stderr = stderr
          @stdout = stdout
        end
      end

      PROCESS_WAIT_TIME = 10

      def self.open_pipe_with_timeout(timeout, *cmd, &block)
        begin
          i, o, e, t, pid = nil

          Timeout.timeout(timeout, ProcessDidNotExitError) do
            i, o, e, t = Open3.popen3(*cmd)
            pid = t.pid
            block.call(i, o, e)

            t.value.exitstatus
          end
        rescue ProcessDidNotExitError => _
          raise ADBCallError, 'Process did not exit'
        ensure
          i.close unless i.nil? || i.closed?
          o.close unless o.nil? || o.closed?
          e.close unless e.nil? || e.closed?

          if pid
            begin
              Process.kill(9, pid)
            rescue Errno::ESRCH => _
              # do nothing
            end
          end

          t.join if t
        end
      end

      def self.open_adb_pipe(*cmd, &block)
        open_pipe_with_timeout(10, Environment.adb_path, *cmd) do |i, o, e|
          block.call(i, o, e) if block
        end
      end

      DAEMON_STARTED_MESSAGE = "* daemon not running. starting it now on port 5037 *\n* daemon started successfully *\n"

      def self.command(*cmd, **args)
        stderr = nil
        stdout = nil
        exit_code = nil

        input = args[:input]

        begin
          exit_code = open_adb_pipe(*cmd) do |i, o, e|
            if input
              input.each do |p_cmd|
                begin
                  i.puts p_cmd
                rescue Errno::EPIPE => err
                  stderr = e.readlines.join
                  stdout = o.readlines.join
                  raise ADBCallError.new(err, stderr, stdout)
                end
              end
            end

            stderr = e.readlines.join
            stdout = o.readlines.join

            if stdout.start_with?(DAEMON_STARTED_MESSAGE)
              stdout = stdout[DAEMON_STARTED_MESSAGE.length..-1]
            end
          end
        rescue IOError => e
          raise ADBCallError, e
        end

        if exit_code != 0
          raise ADBCallError.new(
                "Adb process exited with #{exit_code}", stderr, stdout)
        end

        stdout
      end

      attr_reader :serial

      def initialize(serial)
        @serial = serial
      end

      def command(*argv, **args)
        cmd = argv.dup

        if serial
          cmd.unshift('-s', serial)
        end

        ADB.command(*cmd, args)
      end

      def shell(shell_cmd)
        input =
            [
                shell_cmd,
                'echo $?',
                'exit 0',
            ]

        result = command('shell', input: input)
        out = result.lines[4..-4].join
        exit_code_s = result.lines[-2]

        unless exit_code_s.to_i.to_s == exit_code_s.chomp
          raise ADBCallError,
                "Unable to obtain exit code. Result: '#{exit_code_s}'"
        end

        exit_code = exit_code_s.to_i

        if exit_code != 0
          raise ADBCallError.new(
                    "Adb shell command exited with #{exit_code}", out)
        end

        out
      end

      # @!visibility private
      class ProcessDidNotExitError < RuntimeError; end
    end
  end
end
