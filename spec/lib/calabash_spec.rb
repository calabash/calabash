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

  describe '#_start_test_server' do
    it 'should be have an abstract implementation' do
      expect{dummy.new._start_test_server}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_shutdown_test_server' do
    it 'should be have an abstract implementation' do
      expect{dummy.new._shutdown_test_server}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
