describe Calabash::Application do

  let(:app_path) { File.join(Dir.tmpdir, 'my.app') }

  describe '.new' do
    it 'raises an error if app path does not exist' do
      expect(File).to receive(:exist?).with(app_path).and_return(false)
      expect { Calabash::Application.new(app_path) }.to raise_error RuntimeError
    end

    describe 'option handling' do
      before(:each) do
        expect(File).to receive(:exist?).with(app_path).and_return(true)
      end

      it 'respects the :identifier option' do
        options = { :identifier => 'com.xamarin.flappy-monkey' }
        app = Calabash::Application.new(app_path, options)
        expect(app.identifier).to be == options[:identifier]
      end
    end

    describe '#identifier' do
      let(:app) {Calabash::Application.new(app_path)}

      before(:each) do
        expect(File).to receive(:exist?).with(app_path).and_return(true)
      end

      it 'tries to extract the identifier if it is not set' do
        expect(app).to receive(:extract_identifier).once.and_return('my-identifier')

        2.times {app.identifier}
      end

      it 'will not extract the identifier if it is set' do
        identifier = 'my-id'
        app.instance_variable_set(:@identifier, identifier)

        expect(app).not_to receive(:extract_identifier)

        expect(app.identifier).to be == identifier
      end
    end
  end
end
