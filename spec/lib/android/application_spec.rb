describe Calabash::Android::Application do
  describe '#default_from_environment' do
    it 'should be able to instantiate a new instance of Application with the right information' do
      app_path = 'my-app-path'
      test_server_path = 'my-test-server-path'
      returned_app = :app

      stub_const('Calabash::Environment::APP_PATH', app_path)
      stub_const('Calabash::Environment::TEST_SERVER_PATH', test_server_path)
      allow(File).to receive(:exist?).with(app_path).and_return(true)
      allow(File).to receive(:exist?).with(test_server_path).and_return(true)
      allow(File).to receive(:directory?).with(app_path).and_return(false)
      allow(Calabash::Android::Application).to receive(:new).with(app_path, test_server_path).and_return(returned_app)

      expect(Calabash::Android::Application.default_from_environment).to eq(returned_app)
    end

    it 'should be able to instantiate a new instance of Application with the right information if no test_server is set' do
      app_path = 'my-app-path2'
      test_server_path = 'my-test-server-path2'
      returned_app = :app
      dummy = Class.new {def path; test_server_path; end}.new

      stub_const('Calabash::Environment::APP_PATH', app_path)
      allow(Calabash::Android::Build::TestServer).to receive(:new).with(app_path).and_return(dummy)
      allow(dummy).to receive(:path).and_return(test_server_path)
      allow(Calabash::Android::Application).to receive(:new).with(app_path, test_server_path).and_return(returned_app)
      allow(File).to receive(:exist?).with(app_path).and_return(true)
      allow(File).to receive(:exist?).with(test_server_path).and_return(true)
      allow(File).to receive(:directory?).with(app_path).and_return(false)

      expect(Calabash::Android::Application.default_from_environment).to eq(returned_app)
    end

    it 'should raise an error if the ENV is not sufficient' do
      test_server_path = 'my-test-server-path'

      stub_const('Calabash::Environment::APP_PATH', nil)
      stub_const('Calabash::Environment::TEST_SERVER_PATH', test_server_path)

      expect{Calabash::Android::Application.default_from_environment}.to raise_error('No application path is set')
    end
  end

  describe '#android_application?' do
    let(:app_path) { File.join(Dir.tmpdir, 'my.app') }

    before(:each) do
      expect(File).to receive(:exist?).with(app_path).and_return(true)
    end

    it 'should always return true' do
      expect(Calabash::Android::Application.new(app_path, nil).android_application?).to eq(true)
    end
  end

  describe '#ios_application?' do
    let(:app_path) { File.join(Dir.tmpdir, 'my.app') }

    before(:each) do
      expect(File).to receive(:exist?).with(app_path).and_return(true)
    end

    it 'should always return false' do
      expect(Calabash::Android::Application.new(app_path, nil).ios_application?).to eq(false)
    end
  end
end
