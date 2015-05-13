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

  let(:app) { Calabash::Application.new(abp) }

  it '#calabash_stop_app' do
    bridge.launch
    expect(device.calabash_stop_app).to be_truthy
  end

  it '#screenshot' do
    bridge.launch
    expect(device.screenshot).to be_truthy
  end

  describe '#install_app' do
    describe 'simulators' do
      it 'installs the app' do
        device.install_app(app)
        expect(bridge.app_is_installed?).to be_truthy
      end

      it 're-installs the app if it is already installed' do
        bridge.install
        original_sha = RunLoop::Directory.directory_digest(abp)

        tmp_dir = Dir.mktmpdir
        FileUtils.cp_r(abp, tmp_dir)
        new_abp = File.join(tmp_dir, File.basename(abp))
        File.open(File.join(new_abp, 'file.txt'), 'wb') do |file|
          file.puts 'Hey!'
        end

        new_sha = RunLoop::Directory.directory_digest(new_abp)
        expect(new_sha).not_to be == original_sha

        new_app = Calabash::Application.new(new_abp)
        expect(device.install_app(new_app)).to be_truthy

        installed_app_bundle = bridge.send(:fetch_app_dir)

        installed_app_sha = RunLoop::Directory.directory_digest(installed_app_bundle)
        expect(installed_app_sha).to be == new_sha
      end
    end
  end
end
