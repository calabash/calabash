describe Calabash::LifeCycle do

  let(:device) do
    Class.new(Calabash::Device) do
      def initialize; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
    end.new
  end

  before do
    allow(Calabash::Device).to receive(:default).and_return device
  end

  describe '#stop_app' do
    it 'calls Device.default.stop_app' do
      expect(device).to receive(:stop_app)
      world.stop_app
    end
  end

  describe '#start_app' do
    it 'invokes the implementation method' do
      app = :my_app
      arg = {my: :arg}

      expect(device).to receive(:start_app).with(app, arg)

      world.start_app(app, arg)
    end

    it 'should use the default application if no app is given' do
      app = :my_default_app
      arg = {my: :arg}

      allow(Calabash::Application).to receive(:default).and_return(app)

      expect(device).to receive(:start_app).with(app, arg)

      world.start_app(app, arg)
    end

    it 'should fail if no app is given, and default is not set' do
      allow(Calabash::Application).to receive(:default).and_return(nil)

      expect{world.start_app}.to raise_error 'No application given, and Calabash.default_application is not set'
    end
  end

  describe 'app life cycle' do
    let(:methods) {[:install_app, :ensure_app_installed, :uninstall_app, :clear_app_data]}

    it 'invokes the implementation method' do
      app = :my_app

      methods.each do |method_name|
        expect(device).to receive(:"#{method_name}").with(app)

        world.send(method_name, app)
      end
    end

    it 'should use the default application if no app is given' do
      app = :my_default_app

      allow(Calabash::Application).to receive(:default).and_return(app)

      methods.each do |method_name|
        expect(device).to receive(:"#{method_name}").with(app)

        world.send(method_name)
      end
    end

    it 'should fail if no app is given, and default is not set' do
      allow(Calabash::Application).to receive(:default).and_return(nil)

      methods.each do |method_name|
        expect(device).not_to receive(:"#{method_name}")

        expect do
          world.send(method_name)
        end.to raise_error('No application given, and Calabash.default_application is not set')
      end
    end
  end
end
