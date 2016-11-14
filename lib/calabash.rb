# Calabash is a mobile automation tool used for automatic UI-testing.
# It supports Android and iOS, both native and hybrid app testing.
#
# It is developed and maintained by Xamarin and is released under the Eclipse
# Public License.
module Calabash
  class RequiredBothPlatformsError < LoadError
  end

  require 'calabash/version'
  require 'calabash/environment'
  require 'calabash/logger'
  require 'calabash/color'
  require 'calabash/utility'
  require 'calabash/retry'
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
  require 'calabash/location'
  require 'calabash/orientation'
  require 'calabash/query'
  require 'calabash/text'
  require 'calabash/interactions'
  require 'calabash/web'
  require 'calabash/defaults'
  require 'calabash/legacy'
  require 'calabash/console_helpers'
  require 'calabash/internal'


  require 'calabash/patch'
  Calabash::Patch.apply_patches!


  include Utility
  include Calabash::Wait
  include Calabash::Screenshot
  include Calabash::Gestures
  include Calabash::LifeCycle
  include Calabash::Location
  include Calabash::Orientation
  include Calabash::Text
  include Calabash::Interactions
  include Calabash::Web
  extend Calabash::Defaults

  require 'calabash/page'

  # Instantiate a page object for the current platform.
  #
  # @note Your pages **must** be in the scope of either Android or IOS. See the
  #  examples for details.
  #
  # @example
  #  # android/pages/my_page.rb
  #  class Android::MyPage < Calabash::Page
  #    def method
  #      # [...]
  #    end
  #  end
  #
  #  # step definition
  #  Given(/[...]/) do
  #    # Calabash will determine your platform and pick the Android page.
  #    page(MyPage).method
  #  end
  #
  # @example
  #  # This example shows page code sharing across iOS and Android
  #  # Please see the sample 'shared-page-logic' for details.
  #  # pages/abstract_login_page.rb
  #  class AbstractLoginPage < Calabash::Page
  #    def login(username, password)
  #     cal.enter_text_in(username_field, username)
  #     # [...]
  #    end
  #
  #    private
  #
  #    def username_field
  #      abstract_method!
  #    end
  #  end
  #
  #  # pages/android_login_page.rb
  #  class Android::LoginPage < SharedLoginPage
  #    private
  #
  #    def username_field
  #      "* marked:'a_username'"
  #    end
  #
  #    # [...]
  #  end
  #
  #
  # @see #android?
  # @see #ios?
  # @param [Class] page_class The page to instantiate
  # @return [Calabash::Page] An instance of the page class
  def page(page_class)
    if android?
      platform_module = Object.const_get(:Android)
    elsif ios?
      platform_module = Object.const_get(:IOS)
    else
      raise 'Cannot detect running platform'
    end

    unless page_class.is_a?(Class)
      raise ArgumentError, "Expected a 'Class', got '#{page_class.class}'"
    end

    page_name = page_class.name
    full_page_name = "#{platform_module}::#{page_name}"

    if Calabash.is_defined?(full_page_name)
      page_class = platform_module.const_get(page_name, false)

      if page_class.is_a?(Class)
        modules = page_class.included_modules.map(&:to_s)

        if modules.include?("Calabash::#{platform_module}")
          Logger.warn("Page '#{page_class}' includes Calabash::#{platform_module}. It is recommended not to include Calabash.")
          Logger.warn("Use cal.<method> for cross-platform methods, cal_android.<method> for Android-only and cal_ios.<method> for iOS-only")
        end

        if modules.include?('Calabash::Android') &&
            modules.include?('Calabash::IOS')
          raise "Page '#{page_class}' includes both Calabash::Android and Calabash::IOS"
        end

        unless page_class.ancestors.include?(Calabash::Page)
          raise "Page '#{page_class}' is not a Calabash::Page"
        end

        page = page_class.send(:new, self)

        if page.is_a?(Calabash::Page)
          page
        else
          raise "Page '#{page_class}' is not a Calabash::Page"
        end
      else
        raise "Page '#{page_class}' is not a class"
      end
    else
      raise "No such page defined '#{full_page_name}'"
    end
  end

  # Is the device under test running Android?
  #
  # @return [Boolean] Returns true if
  #  {Calabash::Defaults#default_device Calabash.default_device} is an instance
  #  of {Calabash::Android::Device}.
  def android?
    Android.const_defined?(:Device, false) && Device.default.is_a?(Android::Device)
  end

  # Is the device under test running iOS?
  #
  # @return [Boolean] Returns true if
  #  {Calabash::Defaults#default_device Calabash.default_device} is an instance
  #  of {Calabash::IOS::Device}.
  def ios?
    IOS.const_defined?(:Device, false) && Device.default.is_a?(IOS::Device)
  end

  # @!visibility private
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
  def self.is_defined?(string, scope = Object)
    constant, rest = string.split('::', 2)

    begin
      scope.const_defined?(constant.to_sym, false) &&
          (!rest || is_defined?(rest, scope.const_get(constant, false)))
    rescue NameError => _
      false
    end
  end

  # @!visibility private
  def self.recursive_const_get(string, scope = Object)
    constant, rest = string.split('::', 2)

    if rest
      recursive_const_get(rest, scope.const_get(constant.to_sym, false))
    else
      scope.const_get(constant.to_sym, false)
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

    # @!visibility private
    def self.new_embed_method(method)
      define_method(:embed) do |*args|
        method.call(*args)
      end

      @@has_set_embedding_context = true
    end

    # @!visibility private
    def embed(*_)
      Logger.warn 'Embed is not available in this context. Will not embed.'
    end
  end
end

unless Object.const_defined?(:Android)
  Object.const_set(:Android, Module.new)
end

unless Object.const_defined?(:IOS)
  Object.const_set(:IOS, Module.new)
end

if Calabash::Environment::DEBUG_CALLED_METHODS
  $stdout.puts "#{Calabash::Color.red('Will print every Calabash method called!')}"
  $stdout.puts "#{Calabash::Color.red('Warning: This might slow down your test drastically')}"
  $stdout.puts "#{Calabash::Color.red('and is an experimental feature.')}"

  calabash_file = Calabash.method(:extended).source_location.first
  $__calabash_dir_name = File.dirname(calabash_file)

  trace_func = lambda do |event, file, line, id, binding, classname|
    if event == 'call'
      if classname.to_s.split('::').first == 'Calabash'
        binding_caller_locations = binding.eval('caller_locations')
        files = binding_caller_locations[3..-1].map(&:path)

        calabash_not_in_stacktrace = files.none? do |file|
          file.start_with?($__calabash_dir_name) &&
              File.basename(file) != 'page.rb'
        end

        if calabash_not_in_stacktrace
          unless id == :included || id == :extended || id == :inherited
            arguments = {}

            binding.eval('local_variables').each do |variable|
              arguments[variable] = binding.eval(variable.to_s)
            end

            # The arguments will be in order
            if arguments.empty?
              $stdout.puts "Calabash method called: #{id}"
            else
              $stdout.puts "Calabash method called: #{id}(#{arguments.values.map(&:inspect).join(', ')})"
            end
          end
        end
      end
    end
  end

  set_trace_func(trace_func)
end

# @!visibility private
class CalabashMethodsInternal
  include ::Calabash
end

# @!visibility private
class CalabashMethods < BasicObject
  include ::Calabash

  instance_methods.each do |method_name|
    define_method(method_name) do |*args, &block|
      ::CalabashMethodsInternal.new.send(method_name, *args, &block)
    end
  end
end

# Returns a object that exposes all of the public Calabash cross-platform API.
# This method should *always* be used to access the Calabash API. By default,
# all methods are executed using the default device and the default
# application.
#
# For OS specific methods use {cal_android} and {cal_ios}
#
# All API methods are available with documentation in {Calabash}
#
# @see {Calabash}
#
# @return [Object] Instance responding to all cross-platform Calabash methods
#  in the API.
def cal
  CalabashMethods.new
end
