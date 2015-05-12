describe Calabash::IOS::Environment do

  let(:environment_file) do
    File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'calabash', 'ios', 'environment.rb')
  end

  def _reset_env
    Calabash::IOS::Environment.constants.each do |constant|
      begin
        Calabash::IOS::Environment.send(:remove_const, constant)
      rescue NameError => _

      end
    end
  end

  def _set_env(env)
    _reset_env
    stub_const('ENV', env)
    load environment_file
  end

  def _nil_env
    _set_env({})
  end

  before do
    _reset_env
  end

  after do
    _nil_env
  end

  describe 'constants' do

    it 'returns the correct default values' do
      _nil_env
      uri = Calabash::IOS::Environment::DEVICE_ENDPOINT
      expect(uri).to be_a_kind_of(URI)
      expect(uri.to_s).to be == 'http://localhost:37265'
    end

    it 'returns the correct values if the env is set' do
      _set_env('CAL_ENDPOINT' => 'http://denis.local:37265')
      uri = Calabash::IOS::Environment::DEVICE_ENDPOINT
      expect(uri).to be_a_kind_of(URI)
      expect(uri.to_s).to be == 'http://denis.local:37265'
    end

  end
end
