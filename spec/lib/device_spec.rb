require 'uri'

describe Calabash::Device do

  before(:each) do
    allow_any_instance_of(Calabash::Application).to receive(:ensure_application_path)
  end

  let(:identifier) {:my_identifier}
  let(:server) {Calabash::Server.new(URI.parse('http://localhost:100'), 200)}

  let(:device) {Calabash::Device.new(identifier, server)}

  it 'should have an instance of RetriableHTTPClient initialized' do
    expect(device.http_client).to be_a(Calabash::HTTP::RetriableClient)
  end

  describe '#install' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_install)
        expect(Calabash::Managed).to receive(:install).with(application, device)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.install(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.install(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_install).with(application)
        expect(Calabash::Managed).not_to receive(:install)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.install(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.install(application)
      end
    end
  end

  describe '#uninstall' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}
    
    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_uninstall)
        expect(Calabash::Managed).to receive(:uninstall).with(application, device)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.uninstall(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.uninstall(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_uninstall).with(application)
        expect(Calabash::Managed).not_to receive(:uninstall)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.uninstall(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.uninstall(application)
      end
    end
  end

  describe '#clear_app' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_clear_app)
        expect(Calabash::Managed).to receive(:clear_app).with(application, device)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.clear_app(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.clear_app(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_clear_app).with(application)
        expect(Calabash::Managed).not_to receive(:clear_app)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.clear_app(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.clear_app(application)
      end
    end
  end

  describe '#_install' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_install, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_uninstall' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_uninstall, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_clear_app' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_clear_app, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#ensure_test_server_ready' do
    it 'should raise a runtime error if the test server does not respond' do
      allow(Timeout).to receive(:timeout).with(an_instance_of(Fixnum), Calabash::Device::EnsureTestServerReadyTimeoutError).and_raise(Calabash::Device::EnsureTestServerReadyTimeoutError.new)

      expect{device.ensure_test_server_ready}.to raise_error(RuntimeError)
    end

    it 'should now raise an error if the test server does respond' do
      expect(device).to receive(:test_server_responding?).exactly(5).times.and_return(false, false, false, false, true)

      device.ensure_test_server_ready
    end
  end

  describe '#test_server_responding?' do
    it 'should have an abstract implementation' do
      expect{device.test_server_responding?}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#default' do
    after do
      Calabash::Device.default = nil
    end

    it 'should be able to set its default device' do
      Calabash::Device.default = :my_device
    end

    it 'should be able to get its default device' do
      device = :my_device

      Calabash::Device.default = device

      expect(Calabash::Device.default).to eq(device)
    end
  end

  describe '#parse_path_or_app_parameters' do
    it 'raises an error on invalid arguments' do
      expect { device.send(:parse_path_or_app_parameters, :foo) }.to raise_error ArgumentError
    end

    it 'returns an Application when passed an Application' do
      app = Calabash::Application.new('path/to/my/app')
      expect(device.send(:parse_path_or_app_parameters, app)).to be == app
    end

    it 'returns an Application when passed a String' do
      expected_path = File.expand_path('./path/to/my/app')
      app = device.send(:parse_path_or_app_parameters, expected_path)
      expect(app.path).to be == expected_path
    end
  end

  describe '#parse_identifier_or_app_parameters' do
    it 'raises an error on invalid arguments' do
      expect { device.send(:parse_identifier_or_app_parameters, :foo) }.to raise_error ArgumentError
    end

    it 'returns an identifier when passed an Application' do
      app = Calabash::Application.new('path/to/my/app')
      identifier = 'my-identifier'

      allow(app).to receive(:identifier).and_return(identifier)

      expect(device.send(:parse_identifier_or_app_parameters, app)).to be == identifier
    end

    it 'returns an identifier when passed a String' do
      identifier = 'my-identifier'

      expect(device.send(:parse_identifier_or_app_parameters, identifier)).to be == identifier
    end
  end
end
