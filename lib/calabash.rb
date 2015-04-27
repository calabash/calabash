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

  def self.new_embed_method!(method)
    EmbeddingContext.new_embed_method(method)
  end

  # @!visibility private
  def self.included(base)
    if base.to_s == 'Calabash::Android' || base.to_s == 'Calabash::IOS'
      return
    end

    # These methods will be invoked **before** the base module is mutated.
    # This means that no methods defined in the base module stem from Calabash
    # yet.
    unless base.respond_to?(:embed)
      # The 'embed' method was not defined in the including base module. We
      # don't want to define embed as Calabash's own method, as Calabash should
      # not be globally mutated because of this include. Notice that the
      # embedding context might be mutated. e.g. when Calabash detects it is
      # running in the context of Cucumber. Ruby acknowledges this change in
      # all modules that include the EmbeddingContext module.
      base.send(:include, EmbeddingContext)
    end
  end

  # @!visibility private
  def self.extended(base)
    # We would like to use Cucumber's embed method if possible.
    # This is a hook to obtain this method
    if base.singleton_class.included_modules.map(&:to_s).include?('Cucumber::RbSupport::RbWorld')
      on_cucumber_context(base)
    end
  end

  private

  # @!visibility private
  def self.on_new_context(base)
    cucumber_embed = base.method(:embed)

    unless EmbeddingContext.embedding_context_set?
      new_embed_method!(cucumber_embed)
    end
  end

  # @!visibility private
  def self.on_cucumber_context(base)
    on_new_context(base)
  end

  # @!visibility private
  module EmbeddingContext
    @@has_set_embedding_context ||= false

    def self.embedding_context_set?
      @@has_set_embedding_context
    end

    def self.new_embed_method(method)
      define_method(:embed) do |*args|
        method.call(*args)
      end

      @@has_set_embedding_context = true
    end

    def embed(*_)
      Logger.warn 'Embed is not available in this context. Will not embed.'
    end
  end
end
