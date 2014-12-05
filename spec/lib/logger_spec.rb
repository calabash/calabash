describe Calabash::Logger do
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