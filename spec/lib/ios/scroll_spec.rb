describe Calabash::IOS::Scroll do

  let(:device) do
    Class.new(Calabash::IOS::Device) do
      def initialize; end
      def screenshot(_); end
      def map_route(_, _, *_) ; end
      def to_s; '#<Device>'; end
      def inspect; to_s; end
    end.new
  end

  let(:world) do
    Class.new do
      include Calabash::IOS
      def to_s; '#<Cucumber World>'; end
      def inspect; to_s; end
      def screenshot_embed; ; end
      def wait_for_animations_in(_); ; end
    end.new
  end

  let(:target) do
    Class.new(Calabash::Target) do
    end.new(device, nil)
  end

  before do
    $_target = target

    clz = Class.new do
      def obtain_default_target
        $_target
      end
    end

    allow(Calabash::Internal).to receive(:default_target_state).and_return(clz.new)
  end
  
  # private

  describe '#_wait_for_exactly_one_scroll_view' do
    it 'raises an error if query returns more than one result' do
      expect(world).to receive(:query).and_return([1,2])

      expect do
        world.send(:_wait_for_exactly_one_scroll_view, 'my query')
      end.to raise_error RuntimeError,
                         /Expected 'my query' to match exactly one view, but found/
    end

    it 'raises an error if query returns no results' do
      defaults = Calabash::Wait.class_variable_get(:@@default_options)
      options = defaults.merge({
                                     :timeout => 0.0001,
                                     :retry_frequency => 0.0,
                               })
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:query).at_least(:once).and_return([])

      expect do
        world.send(:_wait_for_exactly_one_scroll_view, 'my query')
      end.to raise_error RuntimeError,
                         /Expected 'my query' to match exactly one view, but found no matches./
    end

    it 'returns the first result of query' do
      expect(world).to receive(:query).and_return([1])

      expect(world.send(:_wait_for_exactly_one_scroll_view, 'my query')).to be == 1
    end
  end

  describe '#_expect_valid_scroll_positions' do
    let(:valid) { [:a, :b, :c] }

    it 'raises an error if position is invalid' do
      expect do
        world.send(:_expect_valid_scroll_positions, valid, :invalid)
      end.to raise_error ArgumentError,
                         /Expected 'invalid' to be one of a, b, c/
    end

    it 'allows symbols and strings' do
      expect do
        world.send(:_expect_valid_scroll_positions, valid, :a)
      end.not_to raise_error

      expect do
        world.send(:_expect_valid_scroll_positions, valid, 'a')
      end.not_to raise_error
    end
  end

  describe '#_expect_valid_scroll_animate' do
    it 'raises an error if animate is not a boolean' do
      expect do
        world.send(:_expect_valid_scroll_animate, nil)
      end.to raise_error ArgumentError,
                         /Expected '' to be a Boolean true or false/
    end

    it 'allows true or false' do
      expect do
        world.send(:_expect_valid_scroll_animate, true)
      end.not_to raise_error

      expect do
        world.send(:_expect_valid_scroll_animate, false)
      end.not_to raise_error
    end
  end

  describe '#_expect_valid_scroll_mark' do
    it 'raises an error for nil mark' do
      expect do
        world.send(:_expect_valid_scroll_mark, nil)
      end.to raise_error ArgumentError,
                         /Mark cannot be nil/
    end

    it 'raises an error for empty string mark' do
      expect do
        world.send(:_expect_valid_scroll_mark, '')
      end.to raise_error ArgumentError,
                         /Mark cannot be an empty string/
    end

    it 'allows valid marks' do
      expect do
        world.send(:_expect_valid_scroll_mark, 'mark!')
      end.not_to raise_error
    end
  end

  # public

  describe '#scroll' do
    describe 'validates the direction argument' do
      it 'raises an error if direction is invalid' do
        expect do
          world.scroll('query', :unknown)
        end.to raise_error ArgumentError, /Expected 'unknown' to be one of/
      end

      it 'allows strings and symbols' do
        expect(Calabash::Query).to receive(:ensure_valid_query).and_return true
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return true
        expect(target).to receive(:map_route).and_return([1])
        expect(Calabash::QueryResult).to receive(:create).and_return true

        expect do
          world.scroll('query', 'down')
        end.not_to raise_error
      end
    end

    describe 'calls map_route and validates the results' do
      let(:query) { 'query' }
      let(:direction) { :down }
      let(:view_to_scroll) { {:id => 'scrollView' } }

      before do
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query)
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return(view_to_scroll)
      end

      it 'raises an error if results are empty' do
        expect(target).to receive(:map_route).with(query, :scroll, direction).and_return([])

        expect do
          world.scroll(query, direction)
        end.to raise_error RuntimeError,
                           /Expected 'query' to match a UIScrollView or a subclass/
      end

      it 'raises an error if first result is nil' do
        expect(target).to receive(:map_route).with(query, :scroll, direction).and_return([nil])

        expect do
          world.scroll(query, direction)
        end.to raise_error RuntimeError,
                           /Expected 'query' to match a UIScrollView or a subclass/
      end
      it 'returns a QueryResult' do
        expect(target).to receive(:map_route).with(query, :scroll, direction).and_return([view_to_scroll])

        result = world.scroll(query, direction)
        expect(result).to be_a_kind_of(Calabash::QueryResult)
        expect(result.query.to_s).to be == query
        expect(result.first).to be == view_to_scroll
      end
    end
  end

  describe '#scroll_to_row' do
    let(:query) { 'query' }
    let(:row) { 1 }
    let(:section) { 2 }

    describe 'validates options and arguments' do
      it 'raises an error if options are not valid' do
        error = ArgumentError.new('Invalid options')
        expect(world).to receive(:_expect_valid_scroll_options).and_raise error

        expect do
          world.scroll_to_row(query, row, section)
        end.to raise_error ArgumentError, /Invalid options/
      end

      it 'raises an error if query is not valid' do
        error = ArgumentError.new('Invalid query')
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query).and_raise error

        expect do
          world.scroll_to_row(query, row, section)
        end.to raise_error ArgumentError, /Invalid query/
      end
    end

    describe 'calls map_route and handles the result' do
      let(:view_to_scroll) { {:id => 'scrollView' } }
      let(:arguments) { [query, :scrollToRow, row, section, :middle, true] }

      before do
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query)
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return(view_to_scroll)
      end

      it 'raises an error if the first result is nil' do
        expect(target).to receive(:map_route).with(*arguments).and_return([nil])

        expect do
          world.scroll_to_row(query, row, section)
        end.to raise_error RuntimeError,
                           /Could not scroll table to row '1' and section '2'/
      end

      it 'raises an error if the first result is []' do
        expect(target).to receive(:map_route).with(*arguments).and_return([])

        expect do
          world.scroll_to_row(query, row, section)
        end.to raise_error RuntimeError,
                           /Could not scroll table to row '1' and section '2'/
      end

      it 'returns a QueryResult' do
        expect(target).to receive(:map_route).with(*arguments).and_return([view_to_scroll])

        result = world.scroll_to_row(query, row, section)
        expect(result).to be_a_kind_of(Calabash::QueryResult)
        expect(result.query.to_s).to be == query
        expect(result.first).to be == view_to_scroll
      end
    end
  end

  describe '#scroll_to_row_with_mark' do
    let(:query) { 'query' }
    let(:mark) { 'mark!' }

    describe 'validates options and arguments' do
      it 'raises an error if options are not valid' do
        error = ArgumentError.new('Invalid options')
        expect(world).to receive(:_expect_valid_scroll_options).and_raise error

        expect do
          world.scroll_to_row_with_mark(query, mark)
        end.to raise_error ArgumentError, /Invalid options/
      end

      it 'raises an error if mark is invalid' do
        error = ArgumentError.new('Invalid mark')
        expect(world).to receive(:_expect_valid_scroll_mark).and_raise error

        expect do
          world.scroll_to_row_with_mark(query, nil)
        end.to raise_error ArgumentError, /Invalid mark/
      end

      it 'raises an error if query is not valid' do
        error = ArgumentError.new('Invalid query')
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query).and_raise error

        expect do
          world.scroll_to_row_with_mark(query, mark)
        end.to raise_error ArgumentError, /Invalid query/
      end
    end

    describe 'calls map_route and handles the result' do
      let(:view_to_scroll) { {:id => 'scrollView' } }
      let(:arguments) { [query, :scrollToRowWithMark, mark, :middle, true] }

      before do
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query)
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return(view_to_scroll)
      end

      it 'raises an error if the first result is nil' do
        expect(target).to receive(:map_route).with(*arguments).and_return([nil])

        expect do
          world.scroll_to_row_with_mark(query, mark)
        end.to raise_error RuntimeError,
                           /Could not scroll table to row with mark: 'mark!'/
      end

      it 'raises an error if the first result is []' do
        expect(target).to receive(:map_route).with(*arguments).and_return([])

        expect do
          world.scroll_to_row_with_mark(query, mark)
        end.to raise_error RuntimeError,
                           /Could not scroll table to row with mark: 'mark!'/
      end

      it 'returns a QueryResult' do
        expect(target).to receive(:map_route).with(*arguments).and_return([view_to_scroll])

        result = world.scroll_to_row_with_mark(query, mark)
        expect(result).to be_a_kind_of(Calabash::QueryResult)
        expect(result.query.to_s).to be == query
        expect(result.first).to be == view_to_scroll
      end
    end
  end

  describe '#scroll_to_item' do
    let(:query) { 'query' }
    let(:item) { 1 }
    let(:section) { 2 }

    describe 'validates options and arguments' do
      it 'raises an error if options are not valid' do
        error = ArgumentError.new('Invalid options')
        expect(world).to receive(:_expect_valid_scroll_options).and_raise error

        expect do
          world.scroll_to_item(query, item, section)
        end.to raise_error ArgumentError, /Invalid options/
      end

      it 'raises an error if query is not valid' do
        error = ArgumentError.new('Invalid query')
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query).and_raise error

        expect do
          world.scroll_to_item(query, item, section)
        end.to raise_error ArgumentError, /Invalid query/
      end
    end

    describe 'calls map_route and handles the result' do
      let(:view_to_scroll) { {:id => 'scrollView' } }
      let(:arguments) { [query, :collectionViewScroll, item, section, :top, true] }

      before do
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query)
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return(view_to_scroll)
      end

      it 'raises an error if the first result is nil' do
        expect(target).to receive(:map_route).with(*arguments).and_return([nil])

        expect do
          world.scroll_to_item(query, item, section)
        end.to raise_error RuntimeError,
                           /Could not scroll collection to item '1' and section '2'/
      end

      it 'raises an error if the first result is []' do
        expect(target).to receive(:map_route).with(*arguments).and_return([])

        expect do
          world.scroll_to_item(query, item, section)
        end.to raise_error RuntimeError,
                           /Could not scroll collection to item '1' and section '2'/
      end

      it 'returns a QueryResult' do
        expect(target).to receive(:map_route).with(*arguments).and_return([view_to_scroll])

        result = world.scroll_to_item(query, item, section)
        expect(result).to be_a_kind_of(Calabash::QueryResult)
        expect(result.query.to_s).to be == query
        expect(result.first).to be == view_to_scroll
      end
    end
  end

  describe '#scroll_to_item_with_mark' do
    let(:query) { 'query' }
    let(:mark) { 'mark!' }

    describe 'validates options and arguments' do
      it 'raises an error if options are not valid' do
        error = ArgumentError.new('Invalid options')
        expect(world).to receive(:_expect_valid_scroll_options).and_raise error

        expect do
          world.scroll_to_item_with_mark(query, mark)
        end.to raise_error ArgumentError, /Invalid options/
      end

      it 'raises an error if mark is invalid' do
        error = ArgumentError.new('Invalid mark')
        expect(world).to receive(:_expect_valid_scroll_mark).and_raise error

        expect do
          world.scroll_to_item_with_mark(query, nil)
        end.to raise_error ArgumentError, /Invalid mark/
      end

      it 'raises an error if query is not valid' do
        error = ArgumentError.new('Invalid query')
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query).and_raise error

        expect do
          world.scroll_to_item_with_mark(query, mark)
        end.to raise_error ArgumentError, /Invalid query/
      end
    end

    describe 'calls map_route and handles the result' do
      let(:view_to_scroll) { {:id => 'scrollView' } }
      let(:arguments) { [query, :collectionViewScrollToItemWithMark, mark, :top, true] }

      before do
        expect(Calabash::Query).to receive(:ensure_valid_query).with(query)
        expect(world).to receive(:_wait_for_exactly_one_scroll_view).and_return(view_to_scroll)
      end

      it 'raises an error if the first result is nil' do
        expect(target).to receive(:map_route).with(*arguments).and_return([nil])

        expect do
          world.scroll_to_item_with_mark(query, mark)
        end.to raise_error RuntimeError,
                           /Could not scroll collection to item with mark: 'mark!'/
      end

      it 'raises an error if the first result is []' do
        expect(target).to receive(:map_route).with(*arguments).and_return([])

        expect do
          world.scroll_to_item_with_mark(query, mark)
        end.to raise_error RuntimeError,
                           /Could not scroll collection to item with mark: 'mark!'/
      end

      it 'returns a QueryResult' do
        expect(target).to receive(:map_route).with(*arguments).and_return([view_to_scroll])

        result = world.scroll_to_item_with_mark(query, mark)
        expect(result).to be_a_kind_of(Calabash::QueryResult)
        expect(result.query.to_s).to be == query
        expect(result.first).to be == view_to_scroll
      end
    end
  end
end
