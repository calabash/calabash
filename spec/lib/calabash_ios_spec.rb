require 'calabash/ios'

describe Calabash::IOS do
  it 'should include Calabash' do
    expect(Calabash::IOS.included_modules).to include(Calabash)
  end
end