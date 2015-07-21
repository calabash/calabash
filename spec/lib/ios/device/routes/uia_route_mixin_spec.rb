describe Calabash::IOS::Routes::UIARouteMixin do

  let(:route_error) { Calabash::IOS::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::HandleRouteMixin
      include Calabash::IOS::Routes::UIARouteMixin

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

  it '#uia_serialize_and_call' do
    expect(device).to receive(:uia_serialize_command).with('command', 1, 2, 3).and_return 'serialized'
    expect(device).to receive(:uia_route).with('serialized').and_return ['result']

    expect(device.send(:uia_serialize_and_call, 'command', 1, 2, 3)).to be == 'result'
  end

  describe 'Serializing UIA commands' do
    describe '#uia_escape_string' do
      it 'calls escape_single_quotes' do
        expected = 'string2'
        expect(Calabash::Text).to receive(:escape_single_quotes).with('String').and_return expected

        expect(device.send(:uia_escape_string, 'String')).to be == expected
      end

      # I am not sure this correct.
      it 'can escape newlines' do
        string = "String with\na newline."
        from_escape_single_quotes = "Expected \n string"
        expected = "Expected \\n string"
        expect(Calabash::Text).to receive(:escape_single_quotes).with(string).and_return from_escape_single_quotes

        expect(device.send(:uia_escape_string, string)).to be == expected
      end
    end

    describe '#uia_serialze_argument' do
      it 'escapes strings' do
        expect(device).to receive(:uia_escape_string).with('String').and_return 'String'

        actual = device.send(:uia_serialize_argument, 'String')
        expect(actual).to be == "'String'"
      end

      describe 'calls to_edn on' do
        it 'Hash' do
          actual = device.send(:uia_serialize_argument, {:a => 'b'})
          expect(actual).to be == "'{:a \"b\"}'"
        end

        it 'Array' do
          actual = device.send(:uia_serialize_argument, [1, 2, 3])
          expect(actual).to be == "'[1 2 3]'"
        end

        it 'Boolean' do
          actual = device.send(:uia_serialize_argument, true)
          expect(actual).to be == "'true'"
        end

        it 'nil' do
          actual = device.send(:uia_serialize_argument, nil)
          expect(actual).to be == "'nil'"
        end
      end
    end

    it '#uia_serialize_arguments' do
      expect(device).to receive(:uia_serialize_argument).with(1).and_return '1'
      expect(device).to receive(:uia_serialize_argument).with(2).and_return '2'
      expect(device).to receive(:uia_serialize_argument).with(3).and_return '3'

      actual = device.send(:uia_serialize_arguments, [1, 2, 3])
      expect(actual).to be == ['1', '2', '3']
    end

    it '#uia_serialize_command' do
      expect(device).to receive(:uia_serialize_arguments).with([1, 2, 3]).and_return ['1', '2', '3']
      actual = device.send(:uia_serialize_command, :tapOffset, 1, 2, 3)
      expect(actual).to be == 'uia.tapOffset(1, 2, 3)'
    end
  end
end
