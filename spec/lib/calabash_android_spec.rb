require 'calabash/android'

describe Calabash::Android do
  it 'should include Calabash' do
    expect(Calabash::Android.included_modules).to include(Calabash)
  end
end