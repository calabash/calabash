describe Calabash::Managed do
  describe '#managed?' do
    it 'should return false by default' do
      expect(Calabash::Managed.managed?).to be false
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

    it 'should never redefine calabash_start_app' do
      args = [:application, :options, :device]
      allow(Calabash::Managed).to receive(:calabash_start_app).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.calabash_start_app(*args)).to eq(correct_value)
    end

    it 'should never redefine calabash_stop_app' do
      args = [:device]
      allow(Calabash::Managed).to receive(:calabash_stop_app).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.calabash_stop_app(*args)).to eq(correct_value)
    end

    it 'should never redefine install_app' do
      args = [:application, :device]
      allow(Calabash::Managed).to receive(:install_app).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.install_app(*args)).to eq(correct_value)
    end

    it 'should never redefine ensure_app_installed' do
      args = [:application, :device]
      allow(Calabash::Managed).to receive(:ensure_app_installed).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.ensure_app_installed(*args)).to eq(correct_value)
    end

    it 'should never redefine uninstall_app' do
      args = [:application, :device]
      allow(Calabash::Managed).to receive(:uninstall_app).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.uninstall_app(*args)).to eq(correct_value)
    end

    it 'should never redefine clear_app' do
      args = [:application, :device]
      allow(Calabash::Managed).to receive(:clear_app).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.clear_app(*args)).to eq(correct_value)
    end

    it 'should never redefine screenshot' do
      allow(Calabash::Managed).to receive(:screenshot).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.screenshot('my name', nil)).to eq(correct_value)
    end

    it 'should never redefine port_forward' do
      allow(Calabash::Managed).to receive(:port_forward).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed.port_forward(12345, nil)).to eq(correct_value)
    end

    it 'should never redefine _managed?' do
      allow(Calabash::Managed).to receive(:_managed?).and_return(correct_value)

      force_require 'calabash/managed'

      expect(Calabash::Managed._managed?).to eq(correct_value)
    end
  end
end
