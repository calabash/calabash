describe Calabash::IOS::Routes::ConditionRouteMixin do

  let(:route_error) { Calabash::IOS::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::ConditionRouteMixin
      include Calabash::IOS::Routes::ResponseParser
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
    it 'returns true for SUCCESS outcome' do
      hash = {'outcome' => 'SUCCESS', 'results' => []}
      expect(JSON).to receive(:parse).and_return(hash)

      expect(device.send(:handle_condition_response, response)).to be_truthy
    end

    it 'returns false for FAILURE outcome' do
      expect(JSON).to receive(:parse).and_return({'outcome' => 'FAILURE'})

      expect(device.send(:handle_condition_response, response)).to be_falsey
    end
  end
end
