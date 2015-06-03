describe Calabash::IOS::KeyboardMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::KeyboardMixin

      def status_bar_orientation; ; end
      def device_family; ; end
    end.new
  end

  let(:keyboard_waiter) do
    Class.new do
      def with_timeout(_); ; end
      def query(_, _); ; end
    end.new
  end

  describe '#docked_keyboard_visible?' do
    it 'false when no keyboard is visible' do
      expect(device).to receive(:query_for_keyboard).and_return([])

      expect(device.docked_keyboard_visible?).to be_falsey
    end

    it 'true if device family iphone' do
      expect(device).to receive(:query_for_keyboard).and_return([1])
      expect(device).to receive(:device_family_iphone?).and_return true

      expect(device.docked_keyboard_visible?).to be_truthy
    end

    describe 'ipad' do
      before do
        expect(device).to receive(:device_family_iphone?).at_least(:once).and_return false
      end

      let(:left_rect) { [{'rect' => {'center_x' => 592, 'center_y' => 512}}] }
      let(:right_rect) { [{'rect' => {'center_x' => 176, 'center_y' => 512}}] }
      let(:up_rect) { [{'rect' => {'center_x' => 384, 'center_y' => 132}}] }
      let(:down_rect) { [{'rect' => {'center_x' => 384, 'center_y' => 892}}] }

      it 'left orientation' do
        expect(device).to receive(:status_bar_orientation).at_least(:once).and_return 'left'
        results = [left_rect, right_rect, up_rect, down_rect]
        expect(device).to receive(:query_for_keyboard).and_return(*results)

        expect(device.docked_keyboard_visible?).to be_truthy
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
      end

      it 'right orientation' do
        expect(device).to receive(:status_bar_orientation).at_least(:once).and_return 'right'
        results = [left_rect, right_rect, up_rect, down_rect]
        expect(device).to receive(:query_for_keyboard).and_return(*results)

        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_truthy
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
      end

      it 'up orientation' do
        expect(device).to receive(:status_bar_orientation).at_least(:once).and_return 'up'
        results = [left_rect, right_rect, up_rect, down_rect]
        expect(device).to receive(:query_for_keyboard).and_return(*results)

        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_truthy
        expect(device.docked_keyboard_visible?).to be_falsey
      end

      it 'down orientation' do
        expect(device).to receive(:status_bar_orientation).at_least(:once).and_return 'down'
        results = [left_rect, right_rect, up_rect, down_rect]
        expect(device).to receive(:query_for_keyboard).and_return(*results)

        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_falsey
        expect(device.docked_keyboard_visible?).to be_truthy
      end

      it 'unknown orientation' do
        expect(device).to receive(:status_bar_orientation).at_least(:once).and_return 'unknown'
        expect(device).to receive(:query_for_keyboard).and_return(left_rect)

        expect(device.docked_keyboard_visible?).to be_falsey
      end
    end

    describe '#undocked_keyboard?' do
      it 'returns false if not an iPad' do
        expect(device).to receive(:device_family_iphone?).and_return true

        expect(device.undocked_keyboard_visible?).to be_falsey
      end

      describe 'iPad' do
        before do
          expect(device).to receive(:device_family_iphone?).and_return false
        end
        it 'returns false if query for keyboard is empty' do
          expect(device).to receive(:query_for_keyboard).and_return([])

          expect(device.undocked_keyboard_visible?).to be_falsey
        end

        describe 'keyboard visible' do
          before do
            expect(device).to receive(:query_for_keyboard).and_return([1])
          end

          it 'returns false if keyboard is visible but docked' do
            expect(device).to receive(:docked_keyboard_visible?).and_return true

            expect(device.undocked_keyboard_visible?).to be_falsey
          end

          it 'returns true if keyboard is visible but not docked' do
            expect(device).to receive(:docked_keyboard_visible?).and_return false
            expect(device.undocked_keyboard_visible?).to be_truthy
          end
        end
      end
    end

    describe '#split_keyboard_visible?' do
      it 'returns false if not an iPad' do
        expect(device).to receive(:device_family_iphone?).and_return true

        expect(device.split_keyboard_visible?).to be_falsey
      end

      describe 'iPad' do
        before do
          expect(device).to receive(:device_family_iphone?).and_return false
        end

        describe 'no visible keyboard using query_for_keyboard' do
          before do
            allow(device).to receive(:query_for_keyboard).and_return([])
          end

          it 'returns false if keyboard key count is 0' do
            expect(device).to receive(:query_for_keyboard_keys).and_return []

            expect(device.split_keyboard_visible?).to be_falsey
          end

          it 'returns true if keyboard key count is > 0' do
            expect(device).to receive(:query_for_keyboard_keys).and_return [1]

            expect(device.split_keyboard_visible?).to be_truthy
          end
        end

        describe 'visible keyboard using query_for_keyboard' do
          before do
            allow(device).to receive(:query_for_keyboard).and_return([1])
          end

          it 'returns false if keyboard key count is 0' do
            expect(device).to receive(:query_for_keyboard_keys).and_return []

            expect(device.split_keyboard_visible?).to be_falsey
          end

          it 'returns false if keyboard key count > 0' do
            expect(device).to receive(:query_for_keyboard_keys).and_return [1]

            expect(device.split_keyboard_visible?).to be_falsey
          end
        end
      end
    end

    describe '#keyboard_visible?' do
      it 'returns false if no keyboard is visible' do
        expect(device).to receive(:docked_keyboard_visible?).and_return false
        expect(device).to receive(:undocked_keyboard_visible?).and_return false
        expect(device).to receive(:split_keyboard_visible?).and_return false

        expect(device.keyboard_visible?).to be_falsey
      end

      it 'returns true if docked keyboard is visible' do
        expect(device).to receive(:docked_keyboard_visible?).and_return true

        expect(device.keyboard_visible?).to be_truthy
      end

      it 'returns true if undocked keyboard is visible' do
        expect(device).to receive(:docked_keyboard_visible?).and_return false
        expect(device).to receive(:undocked_keyboard_visible?).and_return true

        expect(device.keyboard_visible?).to be_truthy
      end

      it 'returns true if split keyboard is visible' do
        expect(device).to receive(:docked_keyboard_visible?).and_return false
        expect(device).to receive(:undocked_keyboard_visible?).and_return false
        expect(device).to receive(:split_keyboard_visible?).and_return true

        expect(device.keyboard_visible?).to be_truthy
      end
    end

    describe '#text_from_keyboard_first_responder' do
      it 'raises error if keyboard is not visible' do
        expect(device).to receive(:keyboard_visible?).and_raise RuntimeError

        expect do
          device.text_from_keyboard_first_responder
        end.to raise_error RuntimeError
      end

      describe 'finds text in UITextField and UITextView' do

        let(:query_method) { :query_for_text_of_first_responder }

        it 'exits early if UITextField is first responder' do
          expect(device).to receive(:keyboard_visible?).and_return true
          expect(device).to receive(query_method).with('textField').and_return 'text'
          expect(device).not_to receive(query_method).with('textView')

          expect(device.text_from_keyboard_first_responder).to be == 'text'
        end

        it 'can find the text of a UITextView' do
          expect(device).to receive(:keyboard_visible?).and_return true
          expect(device).to receive(query_method).with('textField').and_return nil
          expect(device).to receive(query_method).with('textView').and_return 'text'

          expect(device.text_from_keyboard_first_responder).to be == 'text'
        end

        it "returns '' when there is no UITextField or UITextView visible" do
          expect(device).to receive(:keyboard_visible?).and_return true
          expect(device).to receive(query_method).with('textField').and_return nil
          expect(device).to receive(query_method).with('textView').and_return nil

          expect(device.text_from_keyboard_first_responder).to be == ''
        end
      end
    end

    describe '#device_family_iphone?' do
      it 'returns true if the family is iPhone' do
        expect(device).to receive(:device_family).and_return 'iPhone'

        expect(device.send(:device_family_iphone?)).to be_truthy
      end

      it 'returns true if the family is not iPhone' do
        expect(device).to receive(:device_family).and_return 'iPad'

        expect(device.send(:device_family_iphone?)).to be_falsey
      end
    end

    describe 'methods requiring stubbed query' do
      let(:waiter) { device.send(:keyboard_waiter) }

      it '#keyboard_waiter' do
        waiter = device.send(:keyboard_waiter)

        expect(waiter.methods.include?(:query)).to be_truthy
        expect(waiter.methods.include?(:with_timeout)).to be_truthy
        expect(device.instance_variable_get(:@keyboard_waiter)).to be == waiter
      end

      it '#query_for_keyboard' do
        expect(waiter).to receive(:query).and_return []

        expect(device.send(:query_for_keyboard)).to be == []
      end

      it '#query_for_keyboard_keys' do
        expect(waiter).to receive(:query).and_return []

        expect(device.send(:query_for_keyboard_keys)).to be == []
      end

      describe '#query_for_text_of_first_responder' do
        it 'returns nil if result of query is empty' do
          expect(waiter).to receive(:query).and_return []

          expect(device.send(:query_for_text_of_first_responder, 'query')).to be == nil
        end

        it 'returns the first result of query if not empty' do
          expect(waiter).to receive(:query).and_return [1]

          expect(device.send(:query_for_text_of_first_responder, 'query')).to be == 1
        end
      end
    end
  end
end
