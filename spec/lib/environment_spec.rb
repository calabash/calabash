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

  describe '#xamarin_test_cloud?' do
    it 'should return true if the environment variable XAMARIN_TEST_CLOUD is 1' do
      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return('1')

      expect(Calabash::Environment.xamarin_test_cloud?).to be true
    end

    it 'should return false if the environment variable XAMARIN_TEST_CLOUD is not 1' do
      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return('0')

      expect(Calabash::Environment.xamarin_test_cloud?).to be false

      allow(Calabash::Environment).to receive(:variable).with('XAMARIN_TEST_CLOUD').and_return(nil)

      expect(Calabash::Environment.xamarin_test_cloud?).to be false
    end
  end

  describe 'constants' do
    let(:environment_file) {File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'environment.rb')}

    before do
      Calabash::Environment.constants.each {|constant| Calabash::Environment.send(:remove_const, constant)}
    end

    after do
      stub_const('ENV', {'CAL_APP' => nil, 'CAL_WAIT_TIMEOUT' => nil, 'CAL_SCREENSHOT_DIR' => nil})

      load environment_file
    end

    it 'should have the right default values' do
      stub_const('ENV', {'CAL_APP' => nil, 'CAL_WAIT_TIMEOUT' => nil, 'CAL_SCREENSHOT_DIR' => nil})

      load environment_file

      expect(Calabash::Environment::APP_PATH).to eq(nil)
      expect(Calabash::Environment::WAIT_TIMEOUT).to eq(30)
      expect(Calabash::Environment::SCREENSHOT_DIRECTORY).to eq('screenshots')
    end

    it 'should return the correct values if the env is set' do
      stub_const('ENV', {'CAL_APP' => 'my-app', 'CAL_WAIT_TIMEOUT' => '999', 'CAL_SCREENSHOT_DIR' => 'my-directory'})

      load environment_file

      expect(Calabash::Environment::APP_PATH).to eq('my-app')
      expect(Calabash::Environment::WAIT_TIMEOUT).to eq(999)
      expect(Calabash::Environment::SCREENSHOT_DIRECTORY).to eq('my-directory')
    end
  end
end
