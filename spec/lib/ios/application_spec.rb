describe Calabash::IOS::Application do
  describe '#default_from_environment' do
    it 'should be able to instantiate a new instance of Application with the right information' do
      app_path = 'my-app-path'
      returned_app = :app

      stub_const('Calabash::Environment::APP_PATH', app_path)

      allow(Calabash::IOS::Application).to receive(:new).with(app_path).and_return(returned_app)
      expect(Calabash::IOS::Application.default_from_environment).to eq(returned_app)
    end

    it 'should raise an error if the ENV is not sufficient' do
      stub_const('Calabash::Environment::APP_PATH', nil)

      expect{Calabash::IOS::Application.default_from_environment}.to raise_error('No application path is set')
    end
  end

  describe '#.new' do
    let(:path) { IOSResources.instance.app_bundle_path }

    it 'raises an error if the path does point to a .app or .apk' do
      expect(File).to receive(:extname).with(path).at_least(:once).and_return('.png')

      expect {
        Calabash::IOS::Application.new(path)
      }.to raise_error
    end

    it 'sets its instance variables' do
      app = Calabash::IOS::Application.new(path)
      expect(app.instance_variable_get(:@path)).to be_truthy
      expect(app.instance_variable_get(:@simulator_bundle)).to be_truthy
      expect(app.instance_variable_get(:@device_binary)).to be == false
    end
  end

  describe 'instance methods' do
    let(:app) { Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path) }

    it '#simulator_bundle?' do
      app.instance_variable_set(:@simulator_bundle, true)
      expect(app.simulator_bundle?).to be == true
    end

    it '#device_binary?' do
      app.instance_variable_set(:@device_binary, true)
      expect(app.device_binary?).to be == true
    end

    describe '#extract_identifier' do

      let(:identifier) { 'com.example.App' }
      let (:dummy) { Class.new { def bundle_identifier; 'com.example.App'; end }.new }

      it 'from .ipa' do
        expect(app).to receive(:simulator_bundle?).at_least(:once).and_return(false)
        expect(app).to receive(:device_binary?).at_least(:once).and_return(true)
        expect(app).to receive(:run_loop_ipa).and_return(dummy)

        expect(app.send(:extract_identifier)).to be == 'com.example.App'
      end

      it 'from .app' do
        expect(app).to receive(:simulator_bundle?).at_least(:once).and_return(true)
        expect(app).to receive(:run_loop_app).and_return(dummy)

        expect(app.send(:extract_identifier)).to be == 'com.example.App'
      end

      it 'raise error if not an .ipa or .app' do
        expect(app).to receive(:simulator_bundle?).and_return(false)
        expect(app).to receive(:device_binary?).and_return(false)

        expect {
          app.send(:extract_identifier)
        }.to raise_error
      end
    end

    it '#sha1' do
      expect(RunLoop::Directory).to receive(:directory_digest).with(app.path).and_return('sha1')

      expect(app.sha1).to be == 'sha1'
    end

    describe '#same_sha1_as?' do
      let(:dummy) { Class.new { def sha1; 'abcde'; end }.new }

      it 'returns true if sha1 matches' do
        expect(app).to receive(:sha1).and_return('abcde')

        expect(app.same_sha1_as?(dummy)).to be_truthy
      end

      it 'returns false if sha1 does not match' do
        expect(app).to receive(:sha1).and_return('efghi')

        expect(app.same_sha1_as?(dummy)).to be_falsey
      end
    end
  end
end
