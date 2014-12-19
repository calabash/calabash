module Calabash
  require File.join(File.dirname(__FILE__), '..', 'script', 'backwards_compatibility')
  require 'calabash/logger'
  require 'calabash/version'
  require 'calabash/utility'
  require 'calabash/environment'
  require 'calabash/operations'
  require 'calabash/managed'

  include Utility
  include Calabash::Operations

  def start_test_server(opt={})
    _start_test_server(opt)
  end

  def shutdown_test_server(opt={})
    _shutdown_test_server(opt)
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
