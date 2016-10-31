module Calabash
  # @!visibility private
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

    def self.visible?(data)
      (data['visible'] == 1) || data['children'].map{|child| visible?(child)}.any?
    end

    # Attach the current Calabash run-loop to a console.
    #
    # @example
    #  You have encountered a failing cucumber Scenario.
    #  You open the console and want to start investigating the cause of the failure.
    #
    #  Use
    #
    #  > console_attach
    #
    #  to connect to the current run-loop so you can perform gestures.
    #
    # @param [Symbol] uia_strategy Optionally specify the uia strategy, which
    #   can be one of :shared_element, :preferences, :host.  If you don't
    #   know which to choose, don't specify one and calabash will try deduce
    #   the correct strategy to use based on the environment variables used
    #   when starting the console.
    #
    # @return [Hash] The hash will contain the current device, the path to the
    #   current application, and the run-loop strategy.
    #
    # @raise [RuntimeError] If the app is not running.
    def console_attach(uia_strategy=nil)
      Calabash::Application.default = Calabash::IOS::Application.default_from_environment

      identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
      server = Calabash::IOS::Server.default

      device =  Calabash::IOS::Device.new(identifier, server)
      Calabash::Device.default = device

      begin
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.ensure_test_server_ready({:timeout => 4})}
      rescue RuntimeError => e
        if e.to_s == 'Calabash server did not respond'
          raise RuntimeError, 'You can only attach to a running Calabash iOS App'
        else
          raise e
        end
      end

      run_loop_device = device.send(:run_loop_device)
      result = Calabash::Internal.with_default_device(required_os: :ios) {|device| device.send(:attach_to_run_loop, run_loop_device, uia_strategy)}
      result[:application] = Calabash::Application.default
      result
    end
  end
end
