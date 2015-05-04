describe Calabash::Logger do
  describe 'basic logging' do
    before do
      allow_any_instance_of(Calabash::Logger).to receive(:should_log?).and_return(true)
    end

    it 'should be able to output a message and add a newline after it' do
      io = STDOUT.dup
      message = 'My Message'

      expect(io).to receive(:write).with("#{message}\n")

      Calabash::Logger.new(io).log(message)
    end

    it 'should default to STDOUT' do
      expect(STDOUT).to receive(:dup)

      Calabash::Logger.new
    end

    it 'should be able to log using a default logger' do
      message = 'My Message'

      expect(Calabash::Logger).to receive(:log).with(message)

      Calabash::Logger.log(message)
    end
  end

  describe 'log levels' do
    let(:output) {File.new('/dev/null')}
    let(:logger) {Calabash::Logger.new(output)}

    it 'should be able to log with a specified level' do
      log_level = :log_level

      expect(logger).to receive(:should_log?).with(log_level)

      logger.log('message', log_level)
    end

    it 'should be able to log with a default level' do
      local_logger = logger.dup
      log_level = :default_log_level

      expect(local_logger).to receive(:should_log?).with(log_level)

      local_logger.default_log_level = log_level
      local_logger.log('message')
    end

    it 'knows if it should write a certain message' do
      log_level = :log_level
      log_levels = [:a, :b]

      expect(Calabash::Logger).to receive(:log_levels).and_return(log_levels)
      expect(log_levels).to receive(:include?).with(log_level)

      logger.send(:should_log?, log_level)
    end

    describe 'default log levels' do
      let(:logger_file) {File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'logger.rb')}

      describe 'when not in debug mode' do
        it 'should default to info, warn, and error' do
          stub_const('Calabash::Environment::DEBUG', false)
          load logger_file

          expect(Calabash::Logger.log_levels).to eq([:info, :warn, :error])
        end
      end

      describe 'when in debug mode' do
        it 'should default to info, warn, error, and debug' do
          stub_const('Calabash::Environment::DEBUG', true)
          load logger_file

          expect(Calabash::Logger.log_levels).to eq([:info, :warn, :error, :debug])
        end
      end

      after do
        load logger_file
      end
    end

    describe 'methods to log with a specified log level' do
      let(:message) {'message'}

      it 'can log with info level' do
        expect(Calabash::Logger).to receive(:log).with(message, :info)

        Calabash::Logger.info(message)
      end

      it 'can log with debug level' do
        expect(Calabash::Logger).to receive(:log).with(message, :debug)

        Calabash::Logger.debug(message)
      end

      it 'can log with warn level' do
        expect(Calabash::Logger).to receive(:log).with(message, :warn)

        Calabash::Logger.warn(message)
      end

      it 'can log with error level' do
        expect(Calabash::Logger).to receive(:log).with(message, :error)

        Calabash::Logger.error(message)
      end
    end
  end
end