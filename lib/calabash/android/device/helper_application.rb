require 'json'

module Calabash
  module Android
    class Device
      module HelperApplication
        def ensure_helper_application_started
          unless $_calabash_helper_application_started
            $stdout.puts "NEW DEBUG: IN HERE"
            $stdout.puts "NEW DEBUG: INSTALLING"
            install_helper_application
            $stdout.puts "NEW DEBUG: STARTING"
            begin
              start_helper_application
            rescue => e
              $stdout.puts "NEW DEBUG EXCERPICON: #{e.backtrace.join("\n")}"
              raise e
            end

            $stdout.puts "NEW DEBUG: DONE STARTING"
            $_calabash_helper_application_started = true
          end
        end

        def helper_application_server
          Calabash::Android::Server.default_helper
        end

        def helper_application
          Calabash::Android::Application.new(Calabash::Android::HELPER_APPLICATION,
                                             Calabash::Android::HELPER_APPLICATION_TEST_SERVER)
        end

        def helper_application_http_client
          @helper_application_http_client ||= lambda do
            server = Calabash::HTTP::RetriableClient.new(helper_application_server)
            port_forward(helper_application_server.endpoint, helper_application_server.test_server_port)

            server.on_error(Errno::ECONNREFUSED) do |s|
              port_forward(s.endpoint.port, s.test_server_port)
            end

            server
          end.call
        end

        # @!visibility private
        def install_helper_application
          begin
            @logger.log "Ensuring helper application is installed"
            ensure_app_installed(helper_application)
          rescue => e
            @logger.log("Unable to install helper application!", :error)
            raise e
          end

          $_calabash_helper_application_installed = true
        end

        # @!visibility private
        def has_installed_helper_application?
          $_calabash_helper_application_installed
        end

        # @!visibility private
        def helper_application_responding?
          begin
            helper_application_http_client.post(HTTP::Request.new('ping'), retries: 1).body == 'pong'
          rescue HTTP::Error => e
            $stdout.puts "SH NEW DEBUG: PING ERROR #{e.backtrace.join("\n")}"
            false
          end
        end

        def start_helper_application
          cmd = ["am start",
                 "-e testServerPort 0",
                 "-e port 8081",
                 "sh.calaba.calabashhelper/sh.calaba.calabashhelper.MainActivity"].join(" ")

          adb.shell(cmd)

          100.times do |i|
            if i == 99
              raise "Unable to start helper application"
            end

            break if helper_application_responding?
            sleep 1
          end
        end
      end
    end
  end
end