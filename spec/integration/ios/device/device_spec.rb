describe Calabash::IOS::Device do

  let(:sim_name) { RunLoop::Core.default_simulator }

  let(:run_loop_device) do
    RunLoop::SimControl.new.simulators.detect do |sim|
      sim.instruments_identifier == sim_name
    end
  end

  let(:abp) { IOSResources.instance.app_bundle_path }

  let(:bridge) do
    run_loop_app = RunLoop::App.new(abp)
    RunLoop::CoreSimulator.new(run_loop_device, run_loop_app)
  end

  let(:device) do
    uri = URI.parse('http://localhost:37265')
    server = Calabash::IOS::Server.new(uri)
    Calabash::IOS::Device.new(sim_name, server)
  end

  let(:app) { Calabash::IOS::Application.new(abp) }


  it '#stop_app' do
    bridge.launch
    expect(device.stop_app).to be_truthy
  end

  it '#screenshot' do
    bridge.launch
    expect(device.screenshot).to be_truthy
  end

  describe '#install_app' do

    before { bridge.uninstall_app_and_sandbox }

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

        new_app = Calabash::IOS::Application.new(new_abp)
        expect(device.install_app(new_app)).to be_truthy

        installed_app_bundle = bridge.send(:installed_app_bundle_dir)

        installed_app_sha = RunLoop::Directory.directory_digest(installed_app_bundle)
        expect(installed_app_sha).to be == new_sha
      end
    end
  end

  describe 'Starting, clearing app data, and uninstalling' do
    before { bridge.install }

    describe '#start_app' do
      it 'it starts the app on a simulator' do
        device.start_app(app)
      end
    end

    describe '#clear_app_data' do
      it 'clears the app data on a simulator' do
        device.clear_app_data(app)
      end
    end

    describe '#uninstall_app' do
      it 'uninstalls the app from a simulator' do
        device.uninstall_app(app)
      end
    end
  end

  describe 'runtime API' do

    before do
      bridge.install
      device.start_app(app)
    end

    it 'can report runtime attributes' do
      expect(device.device_family).to be == 'iPhone'
      expect(device.form_factor).to be == 'iphone 6'
      expect(device.ios_version).to be == run_loop_device.version
      expect(device.iphone_app_emulated_on_ipad?).to be == false
      expect(device.physical_device?).to be == false
      expect(device.screen_dimensions).to be == {:sample => 1,
                                                 :height => 1334,
                                                 :width => 750,
                                                 :scale => 2}
      run_loop_app = RunLoop::App.new(abp)
      path_to_exec = File.join(abp, run_loop_app.executable_name)
      raw_output = `xcrun strings #{path_to_exec} | grep -E 'CALABASH VERSION'`
      version = raw_output.split(' ')[2]
      expect(device.server_version).to be == RunLoop::Version.new(version)
      expect(device.simulator?).to be == true
    end
  end
end
