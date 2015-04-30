describe Calabash::IOS::Application do
  describe '#default_from_environment' do
    it 'should be able to instantiate a new instance of Application with the right information' do
      app_path = 'my-app-path'
      returned_app = :app

      stub_const('Calabash::Environment::APP_PATH', app_path)

      allow(Calabash::IOS::Application).to receive(:new).with(app_path).and_return(returned_app)
      expect(Calabash::IOS::Application.default_from_environment).to eq(returned_app)
    end
  end
end
