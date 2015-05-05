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

  describe 'app life cycle' do
    let(:methods) {[:install_app, :ensure_app_installed, :uninstall_app, :clear_app_data]}

    it 'should invoke the implementation method' do
      app = :my_app

      methods.each do |method_name|
        expect(dummy_instance).to receive(:"_#{method_name}").with(app)

        dummy_instance.send(method_name, app)
      end
    end

    it 'should use the default application if no app is given' do
      app = :my_default_app

      allow(Calabash::Application).to receive(:default).and_return(app)

      methods.each do |method_name|
        expect(dummy_instance).to receive(:"_#{method_name}").with(app)

        dummy_instance.send(method_name)
      end
    end

    it 'should fail if no app is given, and default is not set' do
      allow(Calabash::Application).to receive(:default).and_return(nil)

      methods.each do |method_name|
        expect(dummy_instance).not_to receive(:"_#{method_name}")

        expect{dummy_instance.send(method_name)}.to raise_error('No application given, and Application.default is not set')
      end
    end
  end

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#_install_app' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(dummy_device).to receive(:install_app).with(arg)

      dummy.new._install_app(arg)
    end
  end

  describe '#_ensure_app_installed' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(dummy_device).to receive(:ensure_app_installed).with(arg)

      dummy.new._ensure_app_installed(arg)
    end
  end

  describe '#_uninstall_app' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:uninstall_app).with(arg)

      dummy.new._uninstall_app(arg)
    end
  end

  describe '#_clear_app_data' do
    it 'should delegate to the default device' do
      arg = 'my-arg'

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:clear_app_data).with(arg)

      dummy.new._clear_app_data(arg)
    end
  end
end
