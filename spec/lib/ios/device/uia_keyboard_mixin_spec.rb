describe Calabash::IOS::UIAKeyboardMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::UIAKeyboardMixin

      def uia_serialize_and_call(_, *_) ; end
      def logger; ; end
    end.new
  end

  let(:handler_class) { Calabash::IOS::UIAKeyboardMixin::UIATypeStringHandler }

  let(:handler) do
    Class.new do
      def handle_result; ; end
    end.new
  end

  describe'#uia_type_string' do
    it 'default options' do
      expect(handler_class).to receive(:escape_backslashes_in_string).with('string').and_return 'escaped'
      expect(device).to receive(:uia_serialize_and_call).with(:typeString, 'escaped', '').and_return({})
      expect(device).to receive(:uia_type_string_handler).and_return(handler)
      expect(handler).to receive(:handle_result).and_return true

      expect(device.uia_type_string('string')).to be_truthy
    end

    describe 'options' do
      it 'respects :existing_text' do
        options = { existing_text: 'existing' }
        expect(handler_class).to receive(:escape_backslashes_in_string).with('string').and_return 'escaped'
        expect(device).to receive(:uia_serialize_and_call).with(:typeString, 'escaped', 'existing').and_return({})
        expect(device).to receive(:uia_type_string_handler).and_return(handler)
        expect(handler).to receive(:handle_result).and_return true

        expect(device.uia_type_string('string', options)).to be_truthy
      end

      it 'respects :escape_backslashes' do
        options = { escape_backslashes: false }
        expect(device).to receive(:uia_serialize_and_call).with(:typeString, 'string', '').and_return({})
        expect(device).to receive(:uia_type_string_handler).and_return(handler)
        expect(handler).to receive(:handle_result).and_return true

        expect(device.uia_type_string('string', options)).to be_truthy
      end
    end
  end

  it '#uia_type_string_handler' do
    expect(handler_class).to receive(:new).with('a', 'b', 'c', 'd', 'e').and_return handler

    expect(device.send(:uia_type_string_handler, 'a', 'b', 'c', 'd', 'e')).to be == handler
  end
end

describe Calabash::IOS::UIAKeyboardMixin::UIATypeStringHandler do

  let(:logger) do
    Class.new do
      def log(message, _); puts message; end
    end.new
  end

  let(:handler_class) { Calabash::IOS::UIAKeyboardMixin::UIATypeStringHandler }

  let(:handler) { handler_class.new('a', 'b', 'c', 'd', logger) }

  describe '.escape_backslashes_in_string' do
    it 'does nothing if there are \ to escape' do
      expect(handler_class.escape_backslashes_in_string('string')).to be == 'string'
    end

    it 'escapes backslashes' do
      string = 'A string \ with \\\ backslashes \\\\.'
      expected = 'A string \\ with \\\\ backslashes \\\\.'
      expect(handler_class.escape_backslashes_in_string(string)).to be == expected
    end
  end

  it '#status' do
    expect(handler).to receive(:result).and_return({'status' => 'success'})

    expect(handler.status).to be == 'success'
  end

  it '#value' do
    expect(handler).to receive(:result).and_return({'value' => {}})

    expect(handler.value).to be == {}
  end

  it '#log' do
    expect(logger).to receive(:log).with('message', :info).and_call_original

    expect(handler.log('message')).to be == nil
  end

  it '#log_preamble' do
    expect(logger).to receive(:log).at_least(:once).and_call_original

    expect(handler.log_preamble).to be == nil
  end

  it '#log_epilogue' do
    expect(logger).to receive(:log).at_least(:once).and_call_original

    expect(handler.log_epilogue).to be == nil
  end

  describe '#handle_error' do
    it "raises error and reports value of 'error' in result" do
      result = {'error' => 'Some error'}
      expect(handler).to receive(:log_preamble)
      expect(handler).to receive(:result).at_least(:once).and_return(result)

      expect do
        expect(handler.handle_error)
      end.to raise_error RuntimeError
    end

    it "raises error and reports entire result if no 'error' in result hash" do
      result = {'value' => 'value', 'status' => 'error'}
      expect(handler).to receive(:log_preamble)
      expect(handler).to receive(:result).at_least(:once).and_return(result)

      expect do
        expect(handler.handle_error)
      end.to raise_error RuntimeError
    end
  end

  it '#handle_unknown_status' do
    expect(handler).to receive(:log_preamble)
    expect(handler).to receive(:status).and_return('unknown')
    expect(handler).to receive(:log).and_call_original
    expect(handler).to receive(:log_epilogue)

    expect(handler.handle_unknown_status).to be_falsey
  end

  describe '#handle_success_with_incident' do
    before do
      expect(handler).to receive(:log_preamble)
      expect(handler).to receive(:log).and_call_original
      expect(handler).to receive(:log_epilogue)
    end


    describe 'when value is nil' do
      it "result has 'value' key but it is nil" do
        expect(handler).to receive(:value).and_return(nil)
        expect(handler).to receive(:result).and_return({'value' => 'val'})

        expect(handler.handle_success_with_incident).to be_falsey
      end

      it "result has no 'value' key" do
        expect(handler).to receive(:value).and_return(nil)
        expect(handler).to receive(:result).and_return({})

        expect(handler.handle_success_with_incident).to be_falsey
      end
    end

    it "result 'value' key => unknown value" do
      expect(handler).to receive(:value).at_least(:once).and_return 'unknown'

      expect(handler.handle_success_with_incident).to be_falsey
    end
  end

  describe '#handle_success' do
    it "result 'value' key => Hash" do
      expect(handler).to receive(:value).and_return({}, {})

      expect(handler.handle_success).to be == {}
    end

    it "result 'value' key => ':nil'" do
      expect(handler).to receive(:value).and_return(':nil', ':nil')

      actual = handler.handle_success
      expect(actual).to be_truthy
      expect(actual).not_to be == ':nil'
    end

    it "result 'value' key is missing or has an unexpected value" do
      expect(handler).to receive(:value).and_return('unexpected', 'unexpected')
      expect(handler).to receive(:handle_success_with_incident)

      expect(handler.handle_success).to be_falsey
    end
  end
end
