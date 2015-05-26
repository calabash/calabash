describe Calabash::HTTP::Request do

  subject { Calabash::HTTP::Request }

  let (:error) {Calabash::HTTP::RequestError}

  describe '.data' do
    describe 'raises errors when' do
      let(:parameters) { 'bad' }
      it 'JSON.generate raises GeneratorError' do
        expect(JSON).to receive(:generate).with(parameters).and_raise JSON::GeneratorError
        expect do
          subject.send(:data, parameters)
        end.to raise_error error
      end

      it 'JSON.generate raise TypeError' do
        expect(JSON).to receive(:generate).with(parameters).and_raise TypeError
        expect do
          subject.send(:data, parameters)
        end.to raise_error error
      end
    end

    describe 'returns JSON when' do
      it 'is passed an Array' do
        parameters = [1, 2, 3]
        actual = subject.send(:data, parameters)
        expect(actual).to be == '[1,2,3]'
      end

      it 'is passed a Hash' do
        parameters = {:offset => {:x => 0, :y => 0}}
        actual = Calabash::HTTP::Request.send(:data, parameters)
        expect(actual).to be == "{\"offset\":{\"x\":0,\"y\":0}}"
      end
    end
  end

  describe '.request' do

    let(:parameters) { {} }

    it 'raises an error if the parameters cannot be converted to JSON' do
      expect(subject).to receive(:data).with(parameters).and_raise error
      expect do
        subject.request('query', parameters)
      end.to raise_error error
    end

    it 'creates a route' do
      expect(subject).to receive(:data).with(parameters).and_return('{}')
      actual = subject.request('query', parameters)
      expect(actual).to be_a_kind_of(subject)
      expect(actual.route).to be == 'query'
      expect(actual.params).to be == '{}'
    end
  end
end
