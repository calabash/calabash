
describe Calabash::IOS::RuntimeAttributes do

  it '.new' do
    attrs = Calabash::IOS::RuntimeAttributes.new({:a => 'a'})
    expect(attrs.instance_variable_get(:@runtime_info)).to be == {:a => 'a'}
  end

  let(:attrs) { Calabash::IOS::RuntimeAttributes.new(nil) }

  describe '#device family' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.device_family).to be == nil
    end

    describe 'simulators' do
      it 'returns value of :simulator_device if it is non-nil and not empty' do
        expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'simulator_device' => 'iPhone'})
        expect(attrs.device_family).to be == 'iPhone'
      end

      it 'returns nil if :simulator_device is empty' do
        expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'simulator_device' => ''})
        expect(attrs.device_family).to be == nil
      end

      it 'returns nil if :simulator_device is nil' do
        expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'simulator_device' => nil})
        expect(attrs.device_family).to be == nil
      end
    end

    describe 'physical devices' do
      it "returns the device family by parsing the value of 'system'" do
        expect(attrs).to receive(:runtime_info).at_least(:once).and_return({ })
        expect(attrs).to receive(:system).and_return('iPhone7,1')
        expect(attrs.device_family).to be == 'iPhone'
      end

      it "returns nil if 'system' is nil" do
        expect(attrs).to receive(:runtime_info).at_least(:once).and_return({ })
        expect(attrs).to receive(:system).and_return(nil)
        expect(attrs.device_family).to be == nil
      end
    end
  end

  describe '#form_factor' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.form_factor).to be == nil
    end

    it 'returns the value of :form_factor' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'form_factor' => 'hello'})
      expect(attrs.form_factor).to be == 'hello'
    end
  end

  describe '#ios_version' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.ios_version).to be == nil
    end

    it 'returns nil if :iOS_version value is nil' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'iOS_version' => nil})
      expect(attrs.ios_version).to be == nil
    end

    it 'returns nil if :iOS_version value is empty' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'iOS_version' => ''})
      expect(attrs.ios_version).to be == nil
    end

    it 'returns a RunLoop::Version if value of :iOS_version can be parsed' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'iOS_version' => '8.1'})
      expect(attrs.ios_version).to be == RunLoop::Version.new('8.1')
    end

    it 'returns nil if :iOS_version value cannot be parsed' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'iOS_version' => '8.1'})
      expect(RunLoop::Version).to receive(:new).and_raise
      expect(attrs.ios_version).to be == nil
    end
  end

  describe '#screen_dimensions' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.screen_dimensions).to be == nil
    end

    it 'returns a hash when screen_dimensions is a hash' do
      dimensions =
          {
              'screen_dimensions' =>
                  {
                      'a' => 1,
                      'b' => 2,
                      'c' => 3
                  }
          }
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return(dimensions)
      expected =
          {
              :a => 1,
              :b => 2,
              :c => 3
          }
      expect(attrs.screen_dimensions).to be == expected
    end
  end

  describe '#server_version' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.server_version).to be == nil
    end

    it 'returns nil if :version value is nil' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'version' => nil})
      expect(attrs.server_version).to be == nil
    end

    it 'returns nil if :version value is empty' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'version' => ''})
      expect(attrs.server_version).to be == nil
    end

    it 'returns a RunLoop::Version if value of :version can be parsed' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'version' => '8.1'})
      expect(attrs.server_version).to be == RunLoop::Version.new('8.1')
    end

    it 'returns nil if :version value cannot be parsed' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'version' => '8.1'})
      expect(RunLoop::Version).to receive(:new).and_raise
      expect(attrs.server_version).to be == nil
    end
  end

  describe '#system' do
    it 'returns nil when runtime info is nil' do
      expect(attrs).to receive(:runtime_info).and_return nil
      expect(attrs.send(:system)).to be == nil
    end

    it 'returns the value of :system' do
      expect(attrs).to receive(:runtime_info).at_least(:once).and_return({'system' => 'hello'})
      expect(attrs.send(:system)).to be == 'hello'
    end
  end
end

