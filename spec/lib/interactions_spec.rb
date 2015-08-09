describe Calabash::Interactions do
  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
    end.new
  end

  describe '#evaluate_javascript_in' do
    it 'should wait for the view to appear' do
      query = 'my query'
      javascript = 'my javascript'

      expect(world).to receive(:wait_for_view)
                           .with(query,
                                 hash_including(timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT))
      allow(world).to receive(:_evaluate_javascript_in)

      world.evaluate_javascript_in(query, javascript)
    end

    it 'should invoke its implementation method' do
      query = 'my query'
      javascript = 'my javascript'

      expect(world).to receive(:_evaluate_javascript_in).with(query, javascript)
      allow(world).to receive(:wait_for_view)

      world.evaluate_javascript_in(query, javascript)
    end
  end
end
