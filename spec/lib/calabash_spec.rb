describe Calabash do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}

  describe '#calabash_start_app' do
    it 'should invoke the implementation method' do
      args = {my: :arg}

      expect(dummy_instance).to receive(:_calabash_start_app).with(args)

      dummy_instance.calabash_start_app(args)
    end
  end

  describe '#calabash_stop_app' do
    it 'should invoke the implementation method' do
      args = {my: :arg}

      expect(dummy_instance).to receive(:_calabash_stop_app).with(args)

      dummy_instance.calabash_stop_app(args)
    end
  end

  describe '#reinstall' do
    it 'should invoke the implementation method' do
      args = {my: :arg}

      expect(dummy_instance).to receive(:_reinstall).with(args)

      dummy_instance.reinstall(args)
    end
  end

  describe '#install' do
    it 'should invoke the implementation method' do
      arg = 'my-arg'

      expect(dummy_instance).to receive(:_install).with(arg)

      dummy_instance.install(arg)
    end
  end

  describe '#uninstall' do
    it 'should invoke the implementation method' do
      arg = 'my-arg'

      expect(dummy_instance).to receive(:_uninstall).with(arg)

      dummy_instance.uninstall(arg)
    end
  end

  describe '#clear_app' do
    it 'should invoke the implementation method' do
      arg = 'my-arg'

      expect(dummy_instance).to receive(:_clear_app).with(arg)

      dummy_instance.clear_app(arg)
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
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(dummy_device).to receive(:install).with(arg)

      dummy.new._install(arg)
    end
  end

  describe '#_uninstall' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:uninstall).with(arg)

      dummy.new._uninstall(arg)
    end
  end

  describe '#_clear_app' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:clear_app).with(arg)

      dummy.new._clear_app(arg)
    end
  end
end
