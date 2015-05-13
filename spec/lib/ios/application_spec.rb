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

  describe 'instance methods' do
    let(:app) { Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path) }

    describe '#simulator_bundle?' do
      it 'returns true if path ends with .app' do
        expect(app).to receive(:path).and_return('./foo.app')
        expect(app.simulator_bundle?).to be_truthy
      end

      it 'returns false if path ends with any other extension' do
        expect(app).to receive(:path).and_return('./foo.png')
        expect(app.simulator_bundle?).to be_falsey
      end
    end

    describe '#device_binary?' do
      it 'returns true if path ends with .ipa' do
        expect(app).to receive(:path).and_return('./foo.ipa')
        expect(app.device_binary?).to be_truthy
      end

      it 'returns false if path ends with any other extension' do
        expect(app).to receive(:path).and_return('./foo.png')
        expect(app.device_binary?).to be_falsey
      end
    end

    describe '#extract_identifier' do

      let(:identifier) { 'com.example.App' }
      let (:dummy) do
        class Calabash::RunLoopLikeApp
          def bundle_identifier
            'com.example.App'
          end
        end
        Calabash::RunLoopLikeApp.new
      end

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
  end
end
