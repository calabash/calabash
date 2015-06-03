describe Calabash do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}

  let(:device) do
    Class.new do
      def start_app(_, _); ; end
      def stop_app; ; end
      def install_app(_); ; end
      def ensure_app_installed(_); ; end
      def uninstall_app(_); ; end
      def clear_app_data(_); ; end
    end.new
  end

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

  before do
    allow(Calabash::Device).to receive(:default).and_return device
  end

  describe '#start_app' do
    it 'calls Device.default.start_app' do
      args = {application: :my_app, my: :arg}
      expect(device).to receive(:start_app).with(:my_app, {my: :arg})

      dummy_instance.start_app(args)
    end

    it 'should use Application.default if no app is given' do
      app = :my_app_2
      args = {my: :arg}

      expect(Calabash::Application).to receive(:default).and_return(app)
      expect(device).to receive(:start_app).with(app, args)

      dummy_instance.start_app(args)
    end

    it 'should fail if no application is given, and Application.default is not set' do
      args = {my: :arg}

      allow(Calabash::Application).to receive(:default).and_return(nil)

      expect do
        dummy_instance.start_app(args)
      end.to raise_error('No application given, and no default application set')
    end
  end

  describe '#stop_app' do
    it 'calls Device.default.stop_app' do
      expect(device).to receive(:stop_app)
      dummy_instance.stop_app
    end
  end

  describe 'app life cycle' do
    let(:methods) {[:install_app, :ensure_app_installed, :uninstall_app, :clear_app_data]}

    it 'invokes the implementation method' do
      app = :my_app

      methods.each do |method_name|
        expect(device).to receive(:"#{method_name}").with(app)

        dummy_instance.send(method_name, app)
      end
    end

    it 'should use the default application if no app is given' do
      app = :my_default_app

      allow(Calabash::Application).to receive(:default).and_return(app)

      methods.each do |method_name|
        expect(device).to receive(:"#{method_name}").with(app)

        dummy_instance.send(method_name)
      end
    end

    it 'should fail if no app is given, and default is not set' do
      allow(Calabash::Application).to receive(:default).and_return(nil)

      methods.each do |method_name|
        expect(device).not_to receive(:"#{method_name}")

        expect do
          dummy_instance.send(method_name)
        end.to raise_error('No application given, and Application.default is not set')
      end
    end
  end
end
