require 'calabash'

unless Object.const_defined?(:Calabash)
  Object.const_set(:Calabash, Module.new)
end

unless Calabash.const_defined?(:Android)
  Calabash.const_set(:Android, Module.new)
end

unless Calabash.const_defined?(:Device)
  Calabash.const_set(:Device, Class.new)
end

unless Calabash::Android.const_defined?(:Device)
  Calabash::Android.const_set(:Device, Class.new(Calabash::Device))
end

unless Calabash.const_defined?(:IOS)
  Calabash.const_set(:IOS, Module.new)
end

unless Calabash::IOS.const_defined?(:Device)
  Calabash::IOS.const_set(:Device, Class.new(Calabash::Device))
end

class Stubs
  def default_serial

  end

  def default_identifier_for_application

  end
end

Calabash::Android::Device.class_eval do
  @_stub_added = false

  define_singleton_method(:singleton_method_added) do |method_name|
    if method_name == :default_serial && !@_stub_added
      @_stub_added = true
      $_orig_default_serial_method = singleton_method(method_name)

      self.define_singleton_method(:default_serial) do
        ::Stubs.new.default_serial
      end
    end

    super(method_name)
  end
end

Calabash::IOS::Device.class_eval do
  @_stub_d_added = false
  @_stub_d_added = false

  define_singleton_method(:singleton_method_added) do |method_name|
    if method_name == :default_identifier_for_application && !@_stub_d_added
      @_stub_d_added = true
      $_orig_default_serial_method = singleton_method(method_name)

      self.define_singleton_method(:default_identifier_for_application) do |application|
        ::Stubs.new.default_identifier_for_application
      end
    end

    if method_name == :expect_compatible_server_endpoint && !@_stub_e_added
      @_stub_e_added = true
      $_orig_default_identifier_for_application_method = singleton_method(method_name)

      self.define_singleton_method(:expect_compatible_server_endpoint) do |identifier, server|
        # Empty
      end
    end

    super(method_name)
  end
end
