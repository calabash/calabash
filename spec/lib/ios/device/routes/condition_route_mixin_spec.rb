describe Calabash::IOS::Routes::ConditionRouteMixin do

  let(:route_error) { Calabash::IOS::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::ConditionRouteMixin
    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  it '#make_condition_parameters' do
    actual = device.send(:make_condition_parameters, 'condition', 'timeout', 'query')
    expected =
          {
           :condition => 'condition',
           :timeout => 'timeout',
           :query => 'query'
          }

    expect(actual).to be == expected
  end

  describe '#handle_condition_response' do
    describe 'raises an error when' do
       describe 'cannot parse the response body' do
         it 'TypeError' do
           expect(JSON).to receive(:parse).and_raise TypeError
           expect {
            device.send(:handle_condition_response, response)
           }.to raise_error route_error
         end

         it 'ParseError' do
           expect(JSON).to receive(:parse).and_raise JSON::ParserError
           expect {
            device.send(:handle_condition_response, response)
           }.to raise_error route_error
         end
       end

       it 'receives an unknown outcome' do
         expect(JSON).to receive(:parse).and_return({'outcome' => 'unknown'})

         expect {
           device.send(:handle_condition_response, response)
         }.to raise_error route_error

         expect(JSON).to receive(:parse).and_return({'outcome' => nil})

         expect {
           device.send(:handle_condition_response, response)
         }.to raise_error route_error
       end
    end

    it 'returns true for SUCCESS outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'SUCCESS'})

      expect(device.send(:handle_condition_response, response)).to be_truthy
    end

    it 'returns false for FAILURE outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'FAILURE'})

      expect(device.send(:handle_condition_response, response)).to be_falsey
    end
  end
end
