module Calabash
  module Android
    require 'calabash'
    require 'calabash/android/environment'
    require_old File.join('ruby-gem', 'lib', 'calabash-android')

    include Calabash
  end
end