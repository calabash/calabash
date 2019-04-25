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
  require 'calabash/target'
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

  # Is the device under test running Android?
  #
  # @return [Boolean] Returns true if the current target is an Android device
  def android?
    Android.const_defined?(:Device, false) &&
        Calabash::Internal.with_current_target {|target| target.device.is_a?(Android::Device)}
  end

  # Is the device under test running iOS?
  #
  # @return [Boolean] Returns true if the current target is an iOS device
  def ios?
    IOS.const_defined?(:Device, false) &&
        Calabash::Internal.with_current_target {|target| target.device.is_a?(IOS::Device)}
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
# @return [CalabashMethods] Instance responding to all cross-platform Calabash methods
#  in the API.
def cal
  CalabashMethods.new
end
