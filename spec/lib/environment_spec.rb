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
end
