describe 'iOS Launch Simulator' do

  let(:server) do
    uri = URI.parse('http://localhost:37265')
    server = Calabash::Server.new(uri)
  end

  let(:app) do
    abp = IOSResources.instance.app_bundle_path
    options = { :identifier => IOSResources.instance.bundle_id }
    Calabash::IOS::Application.new(abp, options)
  end

  let(:target) { RunLoop::Core.default_simulator }

  let(:launch_options) do
    {
          :sim_control => RunLoop::SimControl.new,
          :launch_retries => Luffa::Retry.instance.launch_retries,
    }
  end

  it 'can launch a simulator' do
    device = Calabash::IOS::Device.new(target, server)
    device.start_app(app, launch_options)
  end
end
