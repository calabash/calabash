describe Calabash::Managed do
  describe '#managed?' do
    it 'should return the value of xamarin_test_cloud?' do
      allow(Calabash::Environment).to receive(:xamarin_test_cloud?).and_return(false)

      expect(Calabash::Managed.managed?).to be false

      allow(Calabash::Environment).to receive(:xamarin_test_cloud?).and_return(true)

      expect(Calabash::Managed.managed?).to be true
    end
  end
end
