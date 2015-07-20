describe Calabash::IOS::Routes::ResponseParser do

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::ResponseParser
    end.new
  end

  let(:response) do
    Class.new do
      def body ; end
    end.new
  end

  describe '#parse_response_body' do
    describe 'raises an error when' do
      describe 'cannot parse the response body' do
        it 'TypeError' do
          expect(JSON).to receive(:parse).and_raise TypeError

          expect {
            device.parse_response_body(response)
          }.to raise_error Calabash::IOS::Routes::RouteError
        end

        it 'ParseError' do
          expect(JSON).to receive(:parse).and_raise JSON::ParserError

          expect {
            device.parse_response_body(response)
          }.to raise_error Calabash::IOS::Routes::RouteError
        end
      end
    end

    it 'has unknown outcome value' do
      hash = {'outcome' => 'UNKNOWN'}
      expect(JSON).to receive(:parse).and_return(hash)

      expect {
        device.parse_response_body(response)
      }.to raise_error Calabash::IOS::Routes::RouteError
    end

    it 'outcome was SUCCESS but there is no results key' do
      hash = {'outcome' => 'SUCCESS' }
      expect(JSON).to receive(:parse).and_return(hash)

      expect {
        device.parse_response_body(response)
      }.to raise_error Calabash::IOS::Routes::RouteError
    end

    describe 'outcome was FAILURE' do
      it "fills in missing 'details' key" do
        hash = {
          'outcome' => 'FAILURE',
          'reason'  => 'Request was unreasonable.'
        }
        expect(JSON).to receive(:parse).and_return(hash)

        hash['details'] = 'Server provided no details.'
        actual = device.parse_response_body(response)
        expect(actual).to be == hash

        hash = {
          'outcome' => 'FAILURE',
          'reason'  => 'Request was unreasonable.',
          'details' => ''
        }
        expect(JSON).to receive(:parse).and_return(hash)

        hash['details'] = 'Server provided no details.'
        actual = device.parse_response_body(response)
        expect(actual).to be == hash
      end

      it "fills in missing 'reason' key" do
        hash = {
          'outcome' => 'FAILURE',
          'details'  => 'The sordid details.'
        }
        expect(JSON).to receive(:parse).and_return(hash)

        hash['reason'] = 'Server provided no reason.'
        actual = device.parse_response_body(response)
        expect(actual).to be == hash

        hash = {
          'outcome' => 'FAILURE',
          'details'  => 'The sordid details.',
          'reason' => ''
        }
        expect(JSON).to receive(:parse).and_return(hash)

        hash['details'] = 'Server provided no reason.'
        actual = device.parse_response_body(response)
        expect(actual).to be == hash
      end
    end

    it 'parses valid JSON' do
      json = "{\"outcome\":\"SUCCESS\",\"results\":[\"a\",\"b\",\"c\"]}"
      expect(response).to receive(:body).and_return(json)

      expected = JSON.parse(json)
      actual = device.parse_response_body(response)
      expect(actual).to be == expected
    end
  end
end
