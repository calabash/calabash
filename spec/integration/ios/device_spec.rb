describe Calabash::IOS::Device do

  it '#calabash_stop_app' do
    sim_name = RunLoop::Core.default_simulator
    run_loop_device = RunLoop::SimControl.new.simulators.detect do |sim|
      sim.instruments_identifier == sim_name
    end
    abp = IOSResources.instance.app_bundle_path
    bridge = RunLoop::Simctl::Bridge.new(run_loop_device, abp)
    bridge.install
    bridge.launch

    uri = URI.parse('http://localhost:37265')
    server = Calabash::Server.new(uri)
    device = Calabash::IOS::Device.new(sim_name, server)
    expect(device.calabash_stop_app).to be_truthy
  end
end
