describe Calabash::API do
  let(:operations_class) {Class.new {include Calabash::API}}
  let(:operations) {operations_class.new}
  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#_start_app' do
    let(:app) {:my_app}

    it 'should invoke start_app on the default device' do
      options = {my: :arg}
      dup_options = {my2: :arg2}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(options).to receive(:dup).and_return(dup_options)
      expect(Calabash::Device.default).to receive(:start_app).with(app, dup_options)

      operations._start_app(app, options)
    end
  end

  describe '#_stop_app' do
    it 'should invoke stop_app on the default device' do
      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:stop_app)

      operations._stop_app
    end
  end
end
