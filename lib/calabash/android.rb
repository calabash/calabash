module Calabash
  module Android
    require 'calabash'
    require 'calabash/android/environment'

    # Include old methods
    require_old File.join('ruby-gem', 'lib', 'calabash-android')
    include Calabash::Android::Operations

    include Calabash
  end
end