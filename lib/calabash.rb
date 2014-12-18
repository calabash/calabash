module Calabash
  require File.join(File.dirname(__FILE__), '..', 'script', 'backwards_compatibility')
  require 'calabash/logger'
  require 'calabash/version'
  require 'calabash/utility'
  require 'calabash/environment'
  require 'calabash/operations'

  include Utility
  include Calabash::Operations

  def start_test_server_in_background(opt={})
    _start_test_server_in_background(opt)
  end
end
