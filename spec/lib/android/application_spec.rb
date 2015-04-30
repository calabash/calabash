describe Calabash::Android::Application do
  describe '#default_from_environment' do
    it 'should be able to instantiate a new instance of Application with the right information' do
      app_path = 'my-app-path'
      test_server_path = 'my-test-server-path'
      returned_app = :app

      stub_const('Calabash::Environment::APP_PATH', app_path)
      stub_const('Calabash::Environment::TEST_SERVER_PATH', test_server_path)

      allow(Calabash::Android::Application).to receive(:new).with(app_path, test_server_path).and_return(returned_app)
      expect(Calabash::Android::Application.default_from_environment).to eq(returned_app)
    end
  end
end
