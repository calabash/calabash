describe Calabash do
  let(:dummy) {Class.new {include Calabash}}

  describe '#calabash_start_app' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_calabash_start_app).with(args)

      dummy_instance.calabash_start_app(args)
    end
  end

  describe '#calabash_stop_app' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_calabash_stop_app).with(args)

      dummy_instance.calabash_stop_app(args)
    end
  end

  describe '#reinstall' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_reinstall).with(args)

      dummy_instance.reinstall(args)
    end
  end

  describe '#install' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_install).with(args)

      dummy_instance.install(args)
    end
  end

  describe '#uninstall' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_uninstall).with(args)

      dummy_instance.uninstall(args)
    end
  end

  describe '#_calabash_start_app' do
    it 'should have an abstract implementation' do
      expect{dummy.new._calabash_start_app}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_calabash_stop_app' do
    it 'should have an abstract implementation' do
      expect{dummy.new._calabash_stop_app}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_reinstall' do
    it 'should have an abstract implementation' do
      expect{dummy.new._reinstall}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#_install' do
    it 'should delegate to the default device' do
      params = {my: :param}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(dummy_device).to receive(:install).with(params)

      dummy.new._install(params)
    end
  end

  describe '#_uninstall' do
    it 'should delegate to the default device' do
      params = {my: :param}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:uninstall).with(params)

      dummy.new._uninstall(params)
    end
  end
end
