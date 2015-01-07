module Calabash
  require File.join(File.dirname(__FILE__), '..', 'script', 'backwards_compatibility')
  require 'calabash/logger'
  require 'calabash/version'
  require 'calabash/utility'
  require 'calabash/application'
  require 'calabash/environment'
  require 'calabash/operations'
  require 'calabash/managed'
  require 'calabash/device'
  require 'calabash/server'

  include Utility
  include Calabash::Operations

  def calabash_start_app(opt={})
    _calabash_start_app(opt)
  end

  def calabash_stop_app(opt={})
    _calabash_stop_app(opt)
  end

  def reinstall(opt={})
    _reinstall(opt)
  end

  # Do not modify
  def install(params)
    if Managed.managed?
      Managed.install(params)
    else
      _install(params)
    end
  end

  # Do not modify
  def uninstall(params)
    if Managed.managed?
      Managed.uninstall(params)
    else
      _uninstall(params)
    end
  end
end
