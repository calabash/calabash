# Calabash is a Behavior-driven development (BDD) framework for Android and
# iOS. It supports both native and hybrid app testing.
#
# It is developed and maintained by Xamarin and is released under the Eclipse
# Public License.
module Calabash
  require 'calabash/patch/run_loop'
  require 'calabash/environment'
  require 'calabash/logger'
  require 'calabash/color'
  require 'calabash/utility'
  require 'calabash/application'
  require 'calabash/device'
  require 'calabash/http'
  require 'calabash/server'
  require 'calabash/wait'
  require 'calabash/query'
  require 'calabash/query_result'
  require 'calabash/screenshot'
  require 'calabash/gestures'
  require 'calabash/life_cycle'
  require 'calabash/orientation'
  require 'calabash/query'
  require 'calabash/text'
  require 'calabash/interactions'

  require 'calabash/patch'
  Calabash::Patch.apply_patches!


  include Utility
  include Calabash::Wait
  include Calabash::Screenshot
  include Calabash::Gestures
  include Calabash::LifeCycle
  include Calabash::Orientation
  include Calabash::Text
  include Calabash::Interactions

  def self.new_embed_method!(method)
    EmbeddingContext.new_embed_method(method)
  end

  # @!visibility private
  def self.add_embed_method(base, method)
    # These methods will be invoked **before** the base module is mutated.
    # This means that no methods defined in the base module stem from Calabash
    # yet.
    unless base.respond_to?(:embed)
      # The 'embed' method was not defined in the including base module. We
      # don't want to define embed as Calabash's own method, as Calabash should
      # not be globally mutated because of this include/extend. Notice that the
      # embedding context might be mutated. e.g. when Calabash detects it is
      # running in the context of Cucumber. Ruby acknowledges this change in
      # all modules that include/extend the EmbeddingContext module.
      base.send(method, EmbeddingContext)
    end
  end

  # @!visibility private
  def self.included(base)
    if base.to_s == 'Calabash::Android' || base.to_s == 'Calabash::IOS'
      return
    end

    add_embed_method(base, :include)
  end

  # @!visibility private
  def self.extended(base)
    # We would like to use Cucumber's embed method if possible.
    # This is a hook to obtain this method
    if base.singleton_class.included_modules.map(&:to_s).include?('Cucumber::RbSupport::RbWorld')
      on_cucumber_context(base)
    else
      add_embed_method(base, :extend)
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
