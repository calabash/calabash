describe Calabash::ConsoleHelpers do

  # Use the console to attach to a currently running iOS app that
  # was launched with instruments.
  #
  # :host is always a problem, so expect flickering specs for :host.
  #
  # Don't run the console in the context of bundle exec.  Instead, run rspec
  # in the context of bundle exec: $ be rspec spec/integration/ios
  def calabash_console_with_strategy(application, strategy=nil)
    if strategy.nil?
      attach_cmd = 'console_attach'
    else
      attach_cmd = "console_attach(:#{strategy})"
    end

    Open3.popen3('calabash', *['console', application]) do |stdin, stdout, stderr, _|
      stdin.puts "details = #{attach_cmd}"
      stdin.puts "tap 'textField'"
      stdin.close
      yield stdout, stderr
    end
  end

  describe 'can connect to launched apps' do

    before(:each) { FileUtils.rm_rf(RunLoop::HostCache.default_directory) }


    let(:sim_name) { RunLoop::Core.default_simulator }

    let(:run_loop_device) do
      RunLoop::SimControl.new.simulators.detect do |sim|
        sim.instruments_identifier == sim_name
      end
    end

    let(:app_bundle_path) { IOSResources.instance.app_bundle_path }

    let(:bridge) { RunLoop::Simctl::Bridge.new(run_loop_device, abp) }

    let(:device) do
      uri = URI.parse('http://localhost:37265')
      server = Calabash::IOS::Server.new(uri)
      Calabash::IOS::Device.new(sim_name, server)
    end

    let(:app) { Calabash::IOS::Application.new(app_bundle_path) }

    it ':preferences' do
      device.start_app(app, {:uia_strategy => :preferences})

      calabash_console_with_strategy(app_bundle_path, :preferences) do |stdout, stderr|
        expect(stdout.read.strip[/Error/,0]).to be == nil
        expect(stderr.read.strip).to be == ''
      end
    end

    it ':host' do
      device.start_app(app, {:uia_strategy => :host})

      calabash_console_with_strategy(app_bundle_path, :host) do |stdout, stderr|
        expect(stdout.read.strip[/Error/,0]).to be == nil
        expect(stderr.read.strip).to be == ''
      end
    end

    it ':shared_element' do
      device.start_app(app, {:uia_strategy => :shared_element})

      calabash_console_with_strategy(app_bundle_path, :shared_element) do |stdout, stderr|
        expect(stdout.read.strip[/Error/,0]).to be == nil
        expect(stderr.read.strip).to be == ''
      end
    end
  end
end
