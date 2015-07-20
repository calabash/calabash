describe Calabash::IOS::Routes::BackdoorRouteMixin do
  let(:route_error) { Calabash::IOS::Routes::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::BackdoorRouteMixin
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
    describe 'raises an error when' do
       describe 'cannot parse the response body' do
         it 'TypeError' do
           expect(JSON).to receive(:parse).and_raise TypeError

           expect {
            device.send(:handle_backdoor_response, 'selector:', [], response)
           }.to raise_error route_error
         end

         it 'ParseError' do
           expect(JSON).to receive(:parse).and_raise JSON::ParserError

           expect {
            device.send(:handle_backdoor_response, 'selector:', [], response)
           }.to raise_error route_error
         end
       end

       it 'receives an unknown outcome' do
         expect(JSON).to receive(:parse).and_return({'outcome' => 'unknown'})

         expect {
           device.send(:handle_backdoor_response, 'selector:', [], response)
         }.to raise_error route_error

         expect(JSON).to receive(:parse).and_return({'outcome' => nil})

         expect {
           device.send(:handle_backdoor_response, 'selector:', [], response)
         }.to raise_error route_error
       end
    end

    it 'returns true for SUCCESS outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'SUCCESS',
                                                  'result' => [1]})
      expected = [1]
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

