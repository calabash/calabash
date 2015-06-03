module Calabash
  require 'calabash/patch/run_loop'
  require 'calabash/environment'
  require 'calabash/logger'
  require 'calabash/color'
  require 'calabash/utility'
  require 'calabash/application'
  require 'calabash/api'
  require 'calabash/managed'
  require 'calabash/device'
  require 'calabash/http'
  require 'calabash/server'
  require 'calabash/wait'
  require 'calabash/query'
  require 'calabash/query_result'
  require 'calabash/screenshot'
  require 'calabash/gestures'
  require 'calabash/query'
  require 'calabash/text'

  require 'calabash/patch'
  Calabash::Patch.apply_patches!


  include Utility
  include Calabash::API
  include Calabash::Wait
  include Calabash::Screenshot
  include Calabash::Gestures
  include Calabash::Text

  def start_app(opt={})
    test_options = opt.dup
    application = test_options.fetch(:application, Application.default)
    test_options.delete(:application)

    if application.nil?
      raise 'No application given, and no default application set'
    end

    _start_app(application, test_options)
  end

  def stop_app
    _stop_app
  end

  # Installs the given application. If the application is already installed,
  # the application will be uninstalled, and installed afterwards. If no
  # application is given, it will install `Application.default`.
  #
  # If the given application is an instance of
  # `Calabash::Android::Application`, the same procedure is executed for the
  # test-server of the application, if it is set.
  #
  # @param [String, Calabash::Application] path_or_application A path to the
  #  application, or an instance of `Calabash::Application`. Defaults to
  #  `Application.default`
  def install_app(path_or_application = nil)
    path_or_application ||= Application.default

    unless path_or_application
      raise 'No application given, and Application.default is not set'
    end

    _install_app(path_or_application)
  end

  # Installs the given application *if it is not already installed*. If no
  # application is given, it will ensure `Application.default` is installed.
  #
  # If the given application is an instance of
  # `Calabash::Android::Application`, the same procedure is executed for the
  # test-server of the application, if it is set.
  #
  # @param [String, Calabash::Application] path_or_application A path to the
  #  application, or an instance of `Calabash::Application`. Defaults to
  #  `Application.default`
  def ensure_app_installed(path_or_application = nil)
    path_or_application ||= Application.default

    unless path_or_application
      raise 'No application given, and Application.default is not set'
    end

    _ensure_app_installed(path_or_application)
  end

  # Uninstalls the given application. Does nothing if the application is
  # already uninstalled. If no application is given, it will uninstall
  # `Application.default`.
  #
  # @param [String, Calabash::Application] path_or_application A path to the
  #  application, or an instance of `Calabash::Application`. Defaults to
  #  `Application.default`
  def uninstall_app(path_or_application = nil)
    path_or_application ||= Application.default

    unless path_or_application
      raise 'No application given, and Application.default is not set'
    end

    _uninstall_app(path_or_application)
  end

  # Clears the contents of the given application. This is roughly equivalent to
  # reinstalling the application. If no  application is given, it will clear
  # `Application.default`.
  #
  # @param [String, Calabash::Application] path_or_application A path to the
  #  application, or an instance of `Calabash::Application`. Defaults to
  #  `Application.default`
  def clear_app_data(path_or_application = nil)
    path_or_application ||= Application.default

    unless path_or_application
      raise 'No application given, and Application.default is not set'
    end

    _clear_app_data(path_or_application)
  end

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
