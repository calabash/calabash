describe Calabash do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}

  describe 'when asked to embed' do
    before do
      # Reset EmbeddingContext
      calabash_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash.rb')
      load calabash_file
    end

    it 'should by default warn that embed is impossible' do
      expect(Calabash::Logger).to receive(:warn)
                                      .with('Embed is not available in this context. Will not embed.')

      dummy_instance.embed('a', 'b', 'c')
    end

    it 'should invoke Cucumber\'s embed method when running in context of Cucumber' do
      name = 'my_name'

      module Cucumber
        module RbSupport
          module RbWorld
            def embed(name, *_)
              "MY RESULT #{name}"
            end
          end
        end
      end

      Class.new do
        class << self
          include Cucumber::RbSupport::RbWorld
        end

        extend Calabash

        include Calabash
      end

      expect(dummy_instance.embed(name)).to eq("MY RESULT #{name}")
    end

    it 'should not have embed defined as an instance method' do
      expect(Calabash.instance_methods).not_to include(:embed)
    end
  end

  describe '#calabash_start_app' do
    it 'should invoke the implementation method' do
      args = {application: :my_app, my: :arg}

      expect(dummy_instance).to receive(:_calabash_start_app).with(:my_app, {my: :arg})

      dummy_instance.calabash_start_app(args)
    end

    it 'should use Application.default if no app is given' do
      app = :my_app_2
      args = {my: :arg}

      allow(Calabash::Application).to receive(:default).and_return(app)

      expect(dummy_instance).to receive(:_calabash_start_app).with(app, args)

      dummy_instance.calabash_start_app(args)
    end

    it 'should fail if no application is given, and Application.default is not set' do
      args = {my: :arg}

      allow(Calabash::Application).to receive(:default).and_return(nil)

      expect{dummy_instance.calabash_start_app(args)}.to raise_error('No application given, and no default application set')
    end
  end

  describe '#calabash_stop_app' do
    it 'should invoke the implementation method' do
      expect(dummy_instance).to receive(:_calabash_stop_app)

      dummy_instance.calabash_stop_app
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
