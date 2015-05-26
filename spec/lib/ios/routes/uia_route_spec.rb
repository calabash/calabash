describe Calabash::IOS::Routes::UIARoute do

  let(:route_error) { Calabash::IOS::Routes::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::RouteMixin
      include Calabash::IOS::Routes::UIARoute

      attr_reader :run_loop, :http_client, :uia_strategy

      def initialize
        @http_client =  Class.new do
          def post(_, _); ; end
        end.new
        @run_loop = {:uia_strategy => :preferences}
        @uia_strategy = :preferences
      end

    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  it '#make_uia_parameters' do
    expected =
          {
                :command => 'command'
          }
    expect(device.send(:make_uia_parameters, 'command')).to be == expected
  end

  describe '#uia_route' do
    describe ':preferences' do
      it 'raises error if uia_over_preferences raises an error' do
        expect(device).to receive(:uia_strategy).and_return(:preferences)
        expect(device).to receive(:uia_over_preferences).and_raise StandardError

        expect do
          device.uia_route('command')
        end.to raise_error StandardError
      end

      it 'returns the value of uia_over_host' do
        expect(device).to receive(:uia_strategy).and_return(:preferences)
        expect(device).to receive(:uia_over_preferences).and_return({})

        expect(device.uia_route('command')).to be == {}
      end
    end

    describe ':shared element' do
      it 'raises error if uia_over_preferences raises an error' do
        expect(device).to receive(:uia_strategy).and_return(:shared_element)
        expect(device).to receive(:uia_over_preferences).and_raise StandardError

        expect do
          device.uia_route('command')
        end.to raise_error StandardError
      end

      it 'returns the value of uia_over_host' do
        expect(device).to receive(:uia_strategy).and_return(:shared_element)
        expect(device).to receive(:uia_over_preferences).and_return({})

        expect(device.uia_route('command')).to be == {}
      end
    end

    describe ':host' do
      it 'raises error if uia_over_host raises an error' do
        expect(device).to receive(:uia_strategy).and_return :host
        expect(device).to receive(:uia_over_host).and_raise StandardError

        expect do
          device.uia_route('command')
        end.to raise_error StandardError
      end

      it 'returns the value of uia_over_host' do
        expect(device).to receive(:uia_strategy).and_return :host
        expect(device).to receive(:uia_over_host).and_return({})

        expect(device.uia_route('command')).to be == {}
      end
    end

    it 'raises an error if the uia_strategy is invalid' do
      expect(device).to receive(:uia_strategy).and_return :unknown

      expect do
        device.uia_route('command')
      end.to raise_error route_error
    end

    it 'raises an error if there is no active run_loop' do
      expect(device).to receive(:run_loop).and_return nil

      expect do
        device.uia_route('command')
      end.to raise_error route_error
    end
  end

  describe '#make_uia_request' do
    it 're raises error if Request.request fails' do
      expect(device).to receive(:make_uia_parameters).with('command').and_return 'parameters'
      expect(Calabash::HTTP::Request).to receive(:request).with('uia', 'parameters').and_raise ArgumentError

      expect do
        device.send(:make_uia_request, 'command')
      end.to raise_error route_error
    end

    it 'returns an HTTP request' do
      expect(device).to receive(:make_uia_parameters).with('command').and_return 'parameters'
      expect(Calabash::HTTP::Request).to receive(:request).with('uia', 'parameters').and_return 'request'

      expect(device.send(:make_uia_request, 'command')).to be == 'request'
    end
  end

  describe '#uia_over_preferences' do
    it "makes an http request on the 'uia' route" do
      expect(device).to receive(:make_uia_request).with('command').and_return 'request'
      expect(device).to receive(:route_post_request).with('request').and_return response
      expect(device).to receive(:route_handle_response).with(response, 'command').and_return({})

      expect(device.send(:uia_over_preferences, 'command')).to be == {}
    end
  end

  describe '#uia_over_host' do
    it 'raises error if RunLoop.send_command raises an error' do
      expect(RunLoop).to receive(:send_command).and_raise StandardError

      expect do
        device.send(:uia_over_host, 'command')
      end.to raise_error StandardError
    end

    it 'returns the value of RunLoop.send_command' do
      expect(RunLoop).to receive(:send_command).and_return({})

      expect(device.send(:uia_over_host, 'command')).to be == {}
    end
  end
end
