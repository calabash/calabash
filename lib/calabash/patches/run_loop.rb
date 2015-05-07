require 'run_loop'

if RunLoop::Device.methods.include?(:device_with_identifier)
  puts "\033[35mINFO: RunLoop::Device :device_with_identifier patch can be removed.\033[0m"
else
  puts "\033[35mINFO: patching RunLoop::Device with :device_with_identifier\033[0m"
  module RunLoop
    class Device
      def self.device_with_identifier(udid_or_name, sim_control=RunLoop::SimControl.new)
        simulator = sim_control.simulators.detect do |sim|
          sim.instruments_identifier == udid_or_name ||
                sim.udid == udid_or_name
        end

        return simulator if !simulator.nil?

        physical_device = sim_control.xctools.instruments(:devices).detect do |device|
          puts device
          device.name == udid_or_name ||
                device.udid == udid_or_name
        end

        return physical_device if !physical_device.nil?

        raise ArgumentError, "Could not find a device with a UDID or name matching '#{udid_or_name}'"
      end

      def to_s
        if simulator?
          "Simulator: #{instruments_identifier} #{udid} #{instruction_set}"
        else
          "Device: #{name} #{udid}"
        end
      end
    end
  end
end
