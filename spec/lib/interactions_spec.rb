describe Calabash::Interactions do
  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
    end.new
  end
end
