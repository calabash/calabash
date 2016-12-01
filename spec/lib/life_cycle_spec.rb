describe Calabash::LifeCycle do

  let(:device) do
    Class.new(Calabash::Device) do
      def initialize; end
    end.new
  end

  let(:target) do
    Class.new(Calabash::Target) do
    end.new(device, nil)
  end

  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
    end.new
  end

  before do
    $_target = target

    allow(Calabash::Internal).to receive(:default_target_state).and_return (Class.new do
      def obtain_default_target
        $_target
      end
    end.new)
  end

  describe '#stop_app' do
    it 'calls target.stop_app' do
      expect(target).to receive(:stop_app)
      world.stop_app
    end
  end

  describe '#start_app' do
    it 'invokes the implementation method' do
      arg = {my: :arg}

      expect(target).to receive(:start_app).with(arg)

      world.start_app(arg)
    end
  end

  describe 'app life cycle' do
    let(:methods) {[:install_app, :ensure_app_installed, :uninstall_app, :clear_app_data]}

    it 'invokes the implementation method' do
      methods.each do |method_name|
        expect(target).to receive(:"#{method_name}").with(no_args)

        world.send(method_name)

      end
    end
  end
end
