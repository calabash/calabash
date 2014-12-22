describe Calabash do
  let(:dummy) {Class.new {include Calabash}}

  describe '#start_test_server' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_start_test_server).with(args)

      dummy_instance.start_test_server(args)
    end
  end

  describe '#shutdown_test_server' do
    it 'should invoke the implementation method' do
      dummy_instance = dummy.new
      args = {my: :arg}

      expect(dummy_instance).to receive(:_shutdown_test_server).with(args)

      dummy_instance.shutdown_test_server(args)
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
    it 'should invoke the managed install impl if running in a managed env' do
      dummy_instance = dummy.new
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(dummy_instance).not_to receive(:_install)
      expect(Calabash::Managed).to receive(:install).with(params)

      dummy_instance.install(params)
    end

    it 'should invoke its own managed impl unless running in a managed env' do
      dummy_instance = dummy.new
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(dummy_instance).to receive(:_install).with(params)
      expect(Calabash::Managed).not_to receive(:install)

      dummy_instance.install(params)
    end
  end

  describe '#uninstall' do
    it 'should invoke the managed uninstall impl if running in a managed env' do
      dummy_instance = dummy.new
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(dummy_instance).not_to receive(:_uninstall)
      expect(Calabash::Managed).to receive(:uninstall).with(params)

      dummy_instance.uninstall(params)
    end

    it 'should invoke its own managed impl unless running in a managed env' do
      dummy_instance = dummy.new
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(dummy_instance).to receive(:_uninstall).with(params)
      expect(Calabash::Managed).not_to receive(:uninstall)

      dummy_instance.uninstall(params)
    end
  end

  describe '#_start_test_server' do
    it 'should have an abstract implementation' do
      expect{dummy.new._start_test_server}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_shutdown_test_server' do
    it 'should have an abstract implementation' do
      expect{dummy.new._shutdown_test_server}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_reinstall' do
    it 'should have an abstract implementation' do
      expect{dummy.new._reinstall}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_install' do
    it 'should have an abstract implementation' do
      expect{dummy.new._install({})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_uninstall' do
    it 'should have an abstract implementation' do
      expect{dummy.new._uninstall({})}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
