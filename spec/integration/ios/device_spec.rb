describe Calabash::IOS::Device do

  let(:sim_name) { RunLoop::Core.default_simulator }

  let(:run_loop_device) do
    RunLoop::SimControl.new.simulators.detect do |sim|
      sim.instruments_identifier == sim_name
    end
  end

  let(:abp) { IOSResources.instance.app_bundle_path }

  let(:bridge) { RunLoop::Simctl::Bridge.new(run_loop_device, abp) }

  let(:device) do
    uri = URI.parse('http://localhost:37265')
    server = Calabash::Server.new(uri)
    Calabash::IOS::Device.new(sim_name, server)
  end

  it '#calabash_stop_app' do
    bridge.launch
    expect(device.calabash_stop_app).to be_truthy
  end

  it '#screenshot' do
    bridge.launch
    expect(device.screenshot).to be_truthy
  end
end
