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
  end
end