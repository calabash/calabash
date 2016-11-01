describe Calabash::Retry do
  describe '.retry' do
    before do
      allow(Calabash::Retry).to receive(:sleep)
    end

    it 'has default value for interval' do
      expect(Calabash::Retry::DEFAULT_INTERVAL).to eq(0.5)
    end

    it 'requires retries to be set' do
      expect{Calabash::Retry.retry(retries: nil)}.to raise_error(ArgumentError)
    end

    it 'will run a block <retries> times until it does not raise an error' do
      i = 1

      expect(Calabash::Retry.retry(retries: 10) do
        if i == 5
          i
        else
          i += 1
          raise "Error"
        end
      end).to eq(5)
    end

    it 'will raise the last error if the number of times it calls the block exceeds <retries>' do
      i = 1

      expect{Calabash::Retry.retry(retries: 4) do
        if i == 5
          i
        else
          i += 1
          raise "Error"
        end
      end}.to raise_error(RuntimeError, "Error")
    end

    it 'will sleep for <interval> seconds between retries' do
      expect(Calabash::Retry).to receive(:sleep).with(2).exactly(4).times

      i = 1

      expect(Calabash::Retry.retry(retries: 10, interval: 2) do
        if i == 5
          i
        else
          i += 1
          raise "Error"
        end
      end).to eq(5)
    end

    it 'will sleep for <interval> seconds between retries' do
      expect(Calabash::Retry).to receive(:sleep).with(2).exactly(4).times

      i = 1

      expect(Calabash::Retry.retry(retries: 10, interval: 2) do
        if i == 5
          i
        else
          i += 1
          raise "Error"
        end
      end).to eq(5)
    end

    it 'will timeout between runs if given a timeout' do
      time = Time.now
      expect(Time).to receive(:now).and_return(time)

      i = 1

      expect{Calabash::Retry.retry(retries: 10, interval: 2, timeout: 50) do
        if i == 5
          i
        elsif i == 4
          i += 1
          expect(Time).to receive(:now).and_return(time+51)
          raise "Error"
        else
          expect(Time).to receive(:now).and_return(time+50)
          i += 1
          raise "Old error"
        end
      end}.to raise_error(RuntimeError, "Error")
    end

    it 'will rescue StandardErrors by default' do
      i = 1

      expect{Calabash::Retry.retry(retries: 10) do
        if i == 5
          i
        else
          i += 1
          raise Exception, "Error"
        end
      end}.to raise_error(Exception, "Error")
    end

    it 'can rescue specific errors' do
      i = 1

      expect(Calabash::Retry.retry(retries: 10, on_errors: [RuntimeError]) do
        if i == 5
          i
        else
          i += 1
          raise RuntimeError, "Error"
        end
      end).to eq(5)
    end

    it 'will only rescue the specific errors given' do
      i = 1

      expect{Calabash::Retry.retry(retries: 10, on_errors: [RuntimeError]) do
        if i == 5
          i
        else
          i += 1
          raise StandardError, "Error"
        end
      end}.to raise_error(StandardError, "Error")
    end
  end
end