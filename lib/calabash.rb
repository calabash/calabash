module Calabash
  require File.join(File.dirname(__FILE__), '..', 'script', 'backwards_compatibility')
  require 'calabash/logger'
  require 'calabash/color'
  require 'calabash/version'
  require 'calabash/utility'
  require 'calabash/application'
  require 'calabash/environment'
  require 'calabash/operations'
  require 'calabash/managed'
  require 'calabash/device'
  require 'calabash/http'
  require 'calabash/server'
  require 'calabash/wait'
  require 'calabash/query'
  require 'calabash/query_result'

  include Utility
  include Calabash::Operations
  include Calabash::Wait

  def calabash_start_app(opt={})
    _calabash_start_app(opt)
  end

  def calabash_stop_app(opt={})
    _calabash_stop_app(opt)
  end

  def reinstall(opt={})
    _reinstall(opt)
  end

  def install(path_or_application)
    _install(path_or_application)
  end

  def uninstall(path_or_application)
    _uninstall(path_or_application)
  end

  def clear_app(path_or_application)
    _clear_app(path_or_application)
  end
end
