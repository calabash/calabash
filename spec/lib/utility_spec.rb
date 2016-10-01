describe Calabash::Utility do
  let(:dummy) {Class.new {include ::Calabash::Utility; def foo; abstract_method!; end}}

  describe '#abstract_method!' do
    it 'should raise Calabash::AbstractMethodError' do
      expect{dummy.new.abstract_method!}.to raise_error(::Calabash::AbstractMethodError)
    end

    it 'should mention the method that caused the exception' do
      expect{dummy.new.foo}.to raise_error("Abstract method 'foo'")
    end
  end

  describe '#pct' do
    it 'is an alias for #percent' do
      dummy_instance = dummy.new

      # Strict alias matching is not available in rspec.
      expect(dummy_instance.method(:pct)).to be == dummy_instance.method(:percent)
    end
  end

  describe '#percent' do
    it 'gives a representation of percentage-based coordinates' do
      a = 20
      b = 50

      expect(dummy.new.percent(a, b)).to eq({x: a, y: b})
    end
  end

  describe '#coord' do
    it 'is an alias for #coordinate' do
      dummy_instance = dummy.new

      # Strict alias matching is not available in rspec.
      expect(dummy_instance.method(:coord)).to be == dummy_instance.method(:coordinate)
    end
  end

  describe '#coordinate' do
    it 'gives a representation of a coordinates' do
      a = 20
      b = 50

      expect(dummy.new.coordinate(a, b)).to eq({x: a, y: b})
    end
  end

  describe '.bundler_prepend' do
    it 'returns nothing when this process is not run using bundler' do
      expect(Calabash::Utility).to receive(:used_bundler?).and_return(false)

      expect(Calabash::Utility.bundle_exec_prepend).to eq('')
    end

    it 'returns bundle exec when this process is run using bundler' do
      expect(Calabash::Utility).to receive(:used_bundler?).and_return(true)

      expect(Calabash::Utility.bundle_exec_prepend).to eq('bundle exec ')
    end
  end
end