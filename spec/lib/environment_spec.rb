describe Calabash::Environment do
  describe '#variable' do
    it 'should return the value of an environment variable' do
      environment_variable_name = 'environment_variable_name'
      value_of_environment_variable = 'value_of_environment_variable'

      stub_const('ENV', environment_variable_name => value_of_environment_variable)

      expect(Calabash::Environment.variable(environment_variable_name)).to eq(value_of_environment_variable)
    end
  end

  describe '#set_variable!' do
    it 'should set the value of an environment variable' do
      environment_variable_name = 'environment_variable_name'
      value_of_environment_variable = 'value_of_environment_variable'

      Calabash::Environment.set_variable!(environment_variable_name, value_of_environment_variable)

      expect(ENV[environment_variable_name]).to eq(value_of_environment_variable)
    end
  end

  describe '#default_application_path' do
    it 'should return the default application path' do
      expect(Calabash::Environment).to receive(:variable).with('CALABASH_APP')

      Calabash::Environment.default_application_path
    end
  end

  describe '#xamarin_test_cloud?' do
    it 'should return true if the environment variable XAMARIN_TEST_CLOUD is 1' do
      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return('1')

      expect(Calabash::Environment.xamarin_test_cloud?).to be true
    end

    it 'should return true if the environment variable XAMARIN_TEST_CLOUD is not 1' do
      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return('0')

      expect(Calabash::Environment.xamarin_test_cloud?).to be false

      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return(nil)

      expect(Calabash::Environment.xamarin_test_cloud?).to be false
    end
  end
end
