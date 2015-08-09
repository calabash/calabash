module Calabash
  module Test
    class FakeAndroidDevice
      class << self
        attr_accessor :devices
      end

      FakeAndroidDevice.devices = []

      attr_reader :serial, :status

      def initialize(serial)
        @serial = serial
        @status = 'online'

        @installed_apps =
            [
                {package: 'com.example.foo', path: '/data/app/com.example.foo-2.apk'},
                {package: 'com.example2.foo', path: '/data/app/com.example2.foo-1.apk'},
                {package: 'com.some', path: '/data/app/com.some-1.apk'}
            ]

        @files = []

        @app_history = {}

        @installed_apps.each do |app|
          add_app_history(app[:package], :installed)
        end
      end

      def package_installed?(package)
        @installed_apps.each do |app|
          if app[:package] == package
            return true
          end
        end

        false
      end

      def uninstall_app(package)
        @installed_apps.each do |app|
          $log.write "APP #{app[:package]}. COmpare with #{package}\n"

          if app[:package] == package
            add_app_history(package, :uninstalled)
            @installed_apps.delete(app)
            return
          end
        end

        raise "No such app #{package}"
      end

      def add_app_history(package, data)
        @app_history[package] ||= []
        @app_history[package] << data
      end

      def shell(command)
        captures = command.match(/([^\s]+)\s+(.*)/).captures
        binary = captures[0]
        args = captures[1]

        @return_code = send(:"#{binary}", args)
      end

      def push_file(from, file)
        add_file(file)
      end

      def add_file(with)
        if get_file(path: with[:path])
          raise 'File already exists'
        end

        @files << with
      end

      def get_file(with)
        @files.each do |file|
          with.each do |k, v|
            if file[k] != v
              break
            end

            return file
          end
        end

        nil
      end

      def remove_file(with)
        @files.each do |file|
          with.each do |k, v|
            if file[k] != v
              break
            end

            @files.delete(file)
            return
          end
        end

        raise "No such file #{file}"
      end

      private

      def LIST_HISTORY(args)
        params = args.split(' ')
        package = params.first

        @app_history[package].each do |history|
          out("#{history}\r\n")
        end

        0
      end

      def echo(args)
        case args
          when '$?'
            $log.write("Exit code '#{@return_code}'\n")
            out "#{@return_code}\r\n"
          else
            raise "Invalid args #{args}"
        end
      end

      def rm(args)
        params = args.split(' ')

        file = params.first

        if params.length > 1
          raise "invalid params #{params}"
        end

        if get_file(path: file)
          remove_file(path: file)
          0
        else
          out "rm failed for #{file}, No such file or directory\n"
          255
        end
      end

      def pm(args)
        if args == 'list packages'
          @installed_apps.each {|app| out "package:#{app[:package]}\r\n"}
          0
        elsif args.start_with?('install')
          params = args.split(' ')
          file = params.last
          out "\tpkg: #{file}\r\n"

          if get_file(path: file)
            file = get_file(path: file)
            package = file[:package]

            if !params.include?('-r') && package_installed?(package)
              out "Failure [INSTALL_FAILED_ALREADY_EXISTS]\r\n"
              0
            else
              if package_installed?(package)
                add_app_history(package, :reinstalled)
                out "Success\r\n"
                0
              else
                @installed_apps << {package: package, path: file}
                add_app_history(package, :installed)
                out "Success\r\n"
                0
              end
            end
          else
            out "Failure [INSTALL_FAILED_INVALID_URI]\r\n"
            0
          end
        elsif args.start_with?('uninstall')
          params = args.split(' ')
          package = params.last

          unless package_installed?(package)
            out "Failure\r\n"
            0
          else
            uninstall_app(package)
            out "Success\r\n"
            0
          end
        else
          raise "Invalid args #{args}"
        end
      end
    end
  end
end
