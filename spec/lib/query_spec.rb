describe Calabash::Query do
  describe 'initializing' do
    it 'should accept a string' do
      Calabash::Query.new('my query')
    end

    describe 'when given a string' do
      it 'should duplicate the given string' do
        str = 'foo'
        query = Calabash::Query.new(str)
        str << 'bar'

        expect(query.instance_variable_get(:@query)).to eq('foo')
      end
    end

    it 'should accept a hash' do
      Calabash::Query.new({my: 'query'})
    end

    describe 'when given a hash' do
      it 'should duplicate the given hash' do
        hash = {my: 'hash'}
        query = Calabash::Query.new(hash)
        hash.merge!({dont: 'add'})

        expect(query.instance_variable_get(:@query)).to eq(my: 'hash')
      end
    end

    it 'should accept a Query' do
      Calabash::Query.new(Calabash::Query.new('my query'))
    end

    describe 'when given a Query' do
      it 'should duplicate the given Query' do
        original_query = Calabash::Query.new('my query')
        query = Calabash::Query.new(original_query)

        expect(query.instance_variable_get(:@query)).not_to eq(original_query)
      end
    end

    it 'should not accept anything by a String, a Hash, or a Query' do
      expect{Calabash::Query.new(:foo)}.to raise_error ArgumentError
    end
  end

  describe '#to_s' do
    describe 'when created by a string' do
      it 'should return that string' do
        str = "my query ** \"'foo'"
        query = Calabash::Query.new(str)

        expect(query.to_s).to eq(str)
      end
    end

    describe 'when created by a hash' do
      it 'should return a query string of that hash' do
        hash = {my: 'hash'}
        expected = 'stringified'
        query = Calabash::Query.new(hash)

        expect(Calabash::Query).to receive(:query_hash_to_string).with(hash).and_return(expected)

        expect(query.to_s).to eq(expected)
      end
    end

    describe 'when created by a Query' do
      it 'should return the to_s method of that query' do
        expected = 'original_query to_s'

        to_s_query_class = Class.new(Calabash::Query) do
          define_method(:to_s) do
            expected
          end
        end

        original_query = to_s_query_class.new('my query')
        query = Calabash::Query.new(original_query)

        expect(query.to_s).to eq(expected)
      end
    end
  end

  describe '#self.query_hash_to_string' do
    it 'should return the right string representations' do
      expect(Calabash::Query.query_hash_to_string({class: 'my_class'})).to eq("my_class")
      expect(Calabash::Query.query_hash_to_string({marked: 'my_class'})).to eq("* marked:'my_class'")
      expect(Calabash::Query.query_hash_to_string({marked: 'my_"class'})).to eq("* marked:'my_\"class'")
      expect(Calabash::Query.query_hash_to_string({marked: "my_'class"})).to eq("* marked:'my_\\'class'")
      expect(Calabash::Query.query_hash_to_string({marked: "my_'class", index: 5})).to eq("* marked:'my_\\'class' index:5")
      expect(Calabash::Query.query_hash_to_string({marked: "my_'class", index: 5, css: 'css_selector'})).to eq("* marked:'my_\\'class' index:5 css:'css_selector'")
      expect(Calabash::Query.query_hash_to_string({marked: "my_'class", index: 5, css: "css_'selector"})).to eq("* marked:'my_\\'class' index:5 css:'css_\\'selector'")
      expect(Calabash::Query.query_hash_to_string({css: "css_'selector"})).to eq("* css:'css_\\'selector'")
      expect(Calabash::Query.query_hash_to_string({xpath: "xpath_'selector"})).to eq("* xpath:'xpath_\\'selector'")
      expect(Calabash::Query.query_hash_to_string({class: 'my_class', css: "css_'selector"})).to eq("my_class css:'css_\\'selector'")
    end
  end
end
