describe Array do

  describe '#.to_pct' do
    it 'returns a x,y percentage hash' do
      a = 20
      b = 50
      expect([a, b].to_pct).to be == {x: 20, y: 50}
    end

    context 'raises exception when' do
      subject { [].to_pct }
      it 'there are zero arguments' do
        expect { subject }.to raise_error RangeError
      end

      subject { [20].to_pct }
      it 'there is one argument' do
        expect { subject }.to raise_error RangeError
      end

      subject { [20, 50, 75].to_pct }
      it 'there are three arguments' do
        expect { subject }.to raise_error RangeError
      end
    end
  end
end