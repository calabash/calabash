describe Calabash::IOS::Routes::PlaybackRouteMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::PlaybackRouteMixin
      include Calabash::IOS::Routes::ResponseParser
      include Calabash::IOS::Routes::HandleRouteMixin
    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  it 'PLAYBACK_DIR' do
    directory = device.class.const_get(:PLAYBACK_DIR)
    expect(File.exist?(directory)).to be_truthy
  end

  describe '#read_recording' do
    it 'raises error if recording does not exist' do
      path = '/tmp/foo.txt'
      expect(File).to receive(:exist?).with(path).and_return false

      expect {
        device.send(:read_recording, path)
      }.to raise_error RuntimeError
    end

    it 'returns the contents of the file' do
      path = '/tmp/foo.txt'
      expect(File).to receive(:exist?).with(path).and_return true
      expect(File).to receive(:read).with(path).and_return 'read it!'

      actual = device.send(:read_recording, path)
      expect(actual).to be == 'read it!'
    end
  end

  it '#path_to_recording' do
    stub_const('Calabash::IOS::Routes::PlaybackRouteMixin::PLAYBACK_DIR', '/tmp')
    actual = device.send(:path_to_recording, 'basename', 'S5')
    expect(actual).to be == '/tmp/basename_S5.base64'
  end

  it '#make_playback_parameters' do
    data = 'ABCEDF0123456789'
    expected = "{\"events\":\"ABCEDF0123456789\"}" #{'events' => data}
    actual = device.send(:make_playback_parameters, data)

    expect(actual).to be == expected
  end

  it '#make_playback_request' do
    path = '/tmp/file.txt'
    expect(device).to receive(:path_to_recording).with('name', 'S5').and_return(path)
    expect(device).to receive(:read_recording).with(path).and_return 'data'
    expect(device).to receive(:make_playback_parameters).with('data').and_return 'json'

    actual = device.send(:make_playback_request, 'name', 'S5')
    expect(actual).to be_a_kind_of Calabash::HTTP::Request
    expect(actual.route).to be == 'play'
    expect(actual.params).to be == 'json'
  end

  describe '#playback_route_handle_response' do
    it 'raises an error if outcome is not SUCCESS' do
      hash = {'outcome' => 'FAILURE',
              'reason' => 'A reason.',
              'details' => 'Some details.'}

      expect(device).to receive(:parse_response_body).and_return(hash)

      expect {
        device.send(:playback_route_handle_response, response)
      }.to raise_error RuntimeError
    end

    it 'returns the value of the results key' do
      hash = {'outcome' => 'SUCCESS',
              'results' =>  [1]}

      expect(device).to receive(:parse_response_body).and_return(hash)

      actual = device.send(:playback_route_handle_response, response)
      expect(actual).to be == [1]
    end
  end

  it '#playback_route' do
    name = 'recording'
    form = 'good'
    request = 'request'

    expect(device).to receive(:make_playback_request).with(name, form).and_return(request)
    expect(device).to receive(:route_post_request).with(request).and_return(response)
    expect(device).to receive(:playback_route_handle_response).with(response).and_return('result')
    expect(device).to receive(:recalibrate_after_rotation)

    expect(device.playback_route(name, form)).to be == 'result'
  end
end
