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
end