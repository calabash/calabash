module Calabash
  module ConsoleHelpers
    def self.render(data, indentation)
      if visible?(data)
        type = data['type']

        str_type = if data['type'] == 'dom'
                     "#{Color.yellow("[")}#{type}:#{Color.yellow("#{data['nodeName']}]")} "
                   else
                     Color.yellow("[#{type}] ")
                   end

        str_id = data['id'] ? "[id:#{Color.blue(data['id'])}] " : ''
        str_label = data['label'] ? "[label:#{Color.green(data['label'])}] " : ''
        str_text = data['value'] ? "[text:#{Color.magenta(data['value'])}] " : ''
        output("#{str_type}#{str_id}#{str_label}#{str_text}", indentation)
        output("\n", indentation)
      end
    end

    def console_attach(uia_strategy=nil)
      Calabash::Application.default = Calabash::IOS::Application.default_from_environment

      identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
      server = Calabash::IOS::Server.default

      device =  Calabash::IOS::Device.new(identifier, server)
      Calabash::Device.default = device

      begin
        Calabash::Device.default.ensure_test_server_ready({:timeout => 4})
      rescue RuntimeError => e
        if e.to_s == 'Calabash server did not respond'
          raise RuntimeError, 'You can only attach to a running Calabash iOS App'
        else
          raise e
        end
      end

      run_loop_device = device.send(:run_loop_device)
      result = Calabash::Device.default.send(:attach_to_run_loop, run_loop_device, uia_strategy)
      result[:application] = Calabash::Application.default
    end
  end
end
