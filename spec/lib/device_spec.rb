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

  describe '#start_app' do
    let(:application) {:my_application}
    let(:options) {{my: :opts}}

    describe 'when running in a managed environment' do
      it 'should invoke the managed impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_start_app)
        expect(Calabash::Managed).to receive(:start_app).with(application, options, device)

        device.start_app(application, options)
      end
    end

    describe 'when running in an unmanaged environment' do
      it 'should invoke the impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_start_app).with(application, options)
        expect(Calabash::Managed).not_to receive(:start_app)

        device.start_app(application, options)
      end
    end
  end

  describe '#stop_app' do
    let(:application) {:my_application}
    let(:options) {{my: :opts}}

    describe 'when running in a managed environment' do
      it 'should invoke the managed impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_stop_app)
        expect(Calabash::Managed).to receive(:stop_app).with(device)

        device.stop_app
      end
    end

    describe 'when running in an unmanaged environment' do
      it 'should invoke the impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_stop_app).with(no_args)
        expect(Calabash::Managed).not_to receive(:stop_app)

        device.stop_app
      end
    end
  end

  describe '#install_app' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_install_app)
        expect(Calabash::Managed).to receive(:install_app).with(application, device)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.install_app(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.install_app(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_install_app).with(application)
        expect(Calabash::Managed).not_to receive(:install_app)
      end

      it 'should invoke the impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.install_app(application_path)
      end

      it 'should invoke the impl with the given application when given an application' do
        device.install_app(application)
      end
    end
  end

  describe '#ensure_app_installed' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_ensure_app_installed)
        expect(Calabash::Managed).to receive(:ensure_app_installed).with(application, device)
      end

      it 'should invoke the managed impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.ensure_app_installed(application_path)
      end

      it 'should invoke the managed impl with the given application when given an application' do
        device.ensure_app_installed(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_ensure_app_installed).with(application)
        expect(Calabash::Managed).not_to receive(:ensure_app_installed)
      end

      it 'should invoke the impl with an application when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.ensure_app_installed(application_path)
      end

      it 'should invoke the impl with the given application when given an application' do
        device.ensure_app_installed(application)
      end
    end
  end

  describe '#uninstall_app' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}
    let(:identifier) {'my-identifier'}

    before do
      allow(application).to receive(:identifier).and_return(identifier)
    end

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_uninstall_app)
        expect(Calabash::Managed).to receive(:uninstall_app).with(identifier, device)
      end

      it 'should invoke the managed impl with an identifier when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.uninstall_app(application_path)
      end

      it 'should invoke the managed impl with an identifier when given an application' do
        device.uninstall_app(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_uninstall_app).with(identifier)
        expect(Calabash::Managed).not_to receive(:uninstall_app)
      end

      it 'should invoke the impl with an identifier when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.uninstall_app(application_path)
      end

      it 'should invoke the impl with an identifier application when given an application' do
        device.uninstall_app(application)
      end
    end
  end

  describe '#clear_app_data' do
    let(:application_path) {File.expand_path('./my-application.app')}
    let(:application) {Calabash::Application.new(application_path)}
    let(:identifier) {'my-identifier'}

    before do
      allow(application).to receive(:identifier).and_return(identifier)
    end

    describe 'when running in a managed environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_clear_app_data)
        expect(Calabash::Managed).to receive(:clear_app_data).with(identifier, device)
      end

      it 'should invoke the managed impl with an identifier when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.clear_app_data(application_path)
      end

      it 'should invoke the managed impl with an identifier when given an application' do
        device.clear_app_data(application)
      end
    end

    describe 'when running in an unmanaged environment' do
      before do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_clear_app_data).with(application)
        expect(Calabash::Managed).not_to receive(:clear_app_data)
      end

      it 'should invoke the impl with an identifier when given a path' do
        allow(Calabash::Application).to receive(:new).with(application_path).and_return(application)

        device.clear_app_data(application_path)
      end

      it 'should invoke the impl with the given application when given an application' do
        device.clear_app_data(application)
      end
    end
  end

  describe '#port_forward' do
    let(:host_port) {:my_host_port}

    describe 'when running in a managed environment' do
      it 'should invoke the managed impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_port_forward)
        expect(Calabash::Managed).to receive(:port_forward).with(host_port, device)

        device.port_forward(host_port)
      end
    end

    describe 'when running in an unmanaged environment' do
      it 'should invoke the impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:port_forward).with(host_port)
        expect(Calabash::Managed).not_to receive(:port_forward)

        device.port_forward(host_port)
      end
    end
  end


  describe '#_start_app' do
    it 'should have an abstract implementation' do
      app = :my_app

      expect{device.send(:_start_app, app)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_stop_app' do
    it 'should have an abstract implementation' do
      expect{device.send(:_stop_app)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_install_app' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_install_app, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_ensure_app_installed' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_ensure_app_installed, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_uninstall_app' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_uninstall_app, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_clear_app_data' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_clear_app_data, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_screenshot' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_screenshot, arg)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_port_forward' do
    it 'should have an abstract implementation' do
      arg = 'my-arg'

      expect{device.send(:_port_forward, arg)}.to raise_error(Calabash::AbstractMethodError)
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
      path = "./my-path"
      expected_app = :my_app

      expect(Calabash::Application).to receive(:from_path).with(path).and_return(expected_app)

      expect(device.send(:parse_path_or_app_parameters, path)).to eq(expected_app)
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

  describe '#screenshot' do
    let(:screenshot_name) {'my-screenshot'}

    describe 'when running in a managed environment' do
      it 'should invoke the managed impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(device).not_to receive(:_screenshot)
        expect(Calabash::Managed).to receive(:screenshot).with(screenshot_name, device)

        device.screenshot(screenshot_name)
      end
    end

    describe 'when running in an unmanaged environment' do
      it 'should invoke the managed impl' do
        screenshot_path = :my_screenshot_path

        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(device).to receive(:_screenshot).with(screenshot_path)
        expect(Calabash::Screenshot).to receive(:obtain_screenshot_path!).with(screenshot_name).and_return(screenshot_path)
        expect(Calabash::Managed).not_to receive(:screenshot)

        device.screenshot(screenshot_name)
      end
    end
  end

  describe '#tap' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(device).to receive(:_tap).with(query, hash_including(options))

      device.tap(query, options)
    end

    it 'raises an error if query is not passed' do
      expect do
        device.tap(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        device.tap(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#double_tap' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(device).to receive(:_double_tap).with(query, hash_including(options))

      device.double_tap(query, options)
    end

    it 'raises an error if query is not passed' do
      expect do
        device.double_tap(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        device.double_tap(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#long_press' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(device).to receive(:_long_press).with(query, hash_including(options))

      device.long_press(query, options)
    end

    it 'raises an error if query is not passed' do
      expect do
        device.long_press(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        device.long_press(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#pan' do
    it 'should invoke the implementation method' do
      query = "my query"
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect(device).to receive(:_pan).with(query, from, to, hash_including(options))

      device.pan(query, from, to, options)
    end

    it 'raises an error if query is not passed' do
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect do
        device.pan(nil, from, to, options)
      end.to raise_error ArgumentError

      expect do
        device.pan(:not_a_query, from, to, options)
      end.to raise_error ArgumentError
    end
  end

  describe '#pan_between' do
    it 'should invoke the implementation method' do
      query_from = "my query"
      query_to = "my query 2"
      options = {my: :arg}

      expect(device).to receive(:_pan_between).with(query_from, query_to, hash_including(options))

      device.pan_between(query_from, query_to, options)
    end
    it 'raises an error if invalid query_from' do
      query_from = "my query"
      query_to = "my query 2"

      allow(Calabash::Query).to receive(:valid_query?).with(query_from).and_return(false)

      expect do
        device.pan_between(query_from, query_to)
      end.to raise_error ArgumentError
    end

    it 'raises an error if invalid query_to' do
      query_from = "my query"
      query_to = "my query 2"

      allow(Calabash::Query).to receive(:valid_query?).with(query_from).and_return(true)
      allow(Calabash::Query).to receive(:valid_query?).with(query_to).and_return(false)

      expect do
        device.pan_between(query_from, query_to)
      end.to raise_error ArgumentError
    end
  end


  describe '#flick' do
    it 'should invoke the implementation method' do
      query = "my query"
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect(device).to receive(:_flick).with(query, from, to, hash_including(options))

      device.flick(query, from, to, options)
    end

    it 'raises an error if query is not passed' do
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect do
        device.flick(nil, from, to, options)
      end.to raise_error ArgumentError

      expect do
        device.flick(:not_a_query, from, to, options)
      end.to raise_error ArgumentError
    end
  end

  describe '#_tap' do
    it 'should have an abstract implementation' do
      expect{device.send(:_tap, 'my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_double_tap' do
    it 'should have an abstract implementation' do
      expect{device.send(:_double_tap, 'my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_long_press' do
    it 'should have an abstract implementation' do
      expect{device.send(:_long_press, 'my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_pan' do
    it 'should have an abstract implementation' do
      expect{device.send(:_pan, 'my query', {}, {})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_pan_between' do
    it 'should have an abstract implementation' do
      expect{device.send(:_pan_between, 'my query', 'my query', {})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_flick' do
    it 'should have an abstract implementation' do
      expect{device.send(:_flick, 'my query', {}, {})}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
