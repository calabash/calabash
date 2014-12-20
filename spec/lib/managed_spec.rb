describe Calabash::Managed do
  describe '#managed?' do
    it 'should return the value of xamarin_test_cloud?' do
      allow(Calabash::Environment).to receive(:xamarin_test_cloud?).and_return(false)

      expect(Calabash::Managed.managed?).to be false

      allow(Calabash::Environment).to receive(:xamarin_test_cloud?).and_return(true)

      expect(Calabash::Managed.managed?).to be true
    end
  end

  describe 'it should avoid timing issues by never redefining methods' do
    def force_require(name)
      previous = $LOADED_FEATURES.find {|path| path =~ /#{name}\.rb\z/}

      if previous
        load previous
      else
        require name
      end
    end

    let(:correct_value) {:rspec_correct_value}

    it 'should never redefine install' do
      allow(Calabash::Managed).to receive(:install).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.install({})).to eq(correct_value)
    end

    it 'should never redefine uninstall' do
      allow(Calabash::Managed).to receive(:uninstall).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.uninstall({})).to eq(correct_value)
    end

    it 'should never redefine _managed?' do
      allow(Calabash::Managed).to receive(:_managed?).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed._managed?).to eq(correct_value)
    end
  end
end
