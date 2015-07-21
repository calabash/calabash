describe Calabash::IOS::Routes::BackdoorRouteMixin do
  let(:route_error) { Calabash::IOS::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::BackdoorRouteMixin
      include Calabash::IOS::Routes::ResponseParser
    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  describe 'make_backdoor_parameters' do
    describe 'raises an error when' do
      it 'when a list of length > 1 is passed' do
        arguments = [1, 2]

        expect {
          device.send(:make_backdoor_parameters, 'selector:', arguments)
        }.to raise_error ArgumentError
      end

      it 'when a list of length < 1 is passed' do
        arguments = []

        expect {
          device.send(:make_backdoor_parameters, 'selector:', arguments)
        }.to raise_error ArgumentError
      end

      it 'when selector does not end with :' do
        arguments = [1, 2]
        selector = 'selector'

        expect {
          device.send(:make_backdoor_parameters, selector, arguments)
        }.to raise_error ArgumentError
      end
    end

    it 'assigns key/values correctly' do
      expected = {
        :selector => 'selector:',
        :arg => 'arg!'
      }
      actual = device.send(:make_backdoor_parameters, 'selector:', ['arg!'])
      expect(actual).to be == expected
    end
  end

  describe '#handle_backdoor_response' do
    it 'returns true for SUCCESS outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'SUCCESS',
                                                  'results' => [1]})
      expected = [1]
      actual = device.send(:handle_backdoor_response, 'selector:', [], response)
      expect(actual).to be == expected

      # Legacy API: will be removed in iOS Server > 0.14.3
      expect(JSON).to receive(:parse).and_return({'outcome' => 'SUCCESS',
                                                  'result' => [1]})
      expected = [1]
      actual = device.send(:handle_backdoor_response, 'selector:', [], response)
      expect(actual).to be == expected

      expect(JSON).to receive(:parse).and_return({'outcome' => 'SUCCESS',
                                                  'results' => 'results',
                                                  'result' => 'result'})
      expected = 'results'
      actual = device.send(:handle_backdoor_response, 'selector:', [], response)
      expect(actual).to be == expected
    end

    it 'returns false for FAILURE outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'FAILURE',
                                                  'details' => 'Details!',
                                                  'reason' => 'Reason!'})

      expect {
        device.send(:handle_backdoor_response, 'selector:', [], response)
      }.to raise_error Calabash::IOS::BackdoorError
    end
  end
end

