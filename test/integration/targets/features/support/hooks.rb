def stub_default_serial(&block)
  Stubs.class_eval do
    define_method(:default_serial) do
      block.call
    end
  end
end

def stub_default_identifier_for_application(&block)
  Stubs.class_eval do
    define_method(:default_identifier_for_application) do
      block.call
    end
  end
end

Before do |scenario|
  if $_orig_default_serial_method
    stub_default_serial do
      $_orig_default_serial_method.call
    end
  end

  if $_orig_default_identifier_for_application_method
    stub_default_identifier_for_application do
      $_orig_default_identifier_for_application_method.call
    end
  end
end

After("@full_reset") do
  if Object.const_defined?(:Calabash)
    if Calabash.const_defined?(:AndroidInternal)
      begin
        Calabash.send(:remove_const, :AndroidInternal)
      rescue => e
      end
    end

    if Calabash.const_defined?(:IOSInternal)
      begin
        Calabash.send(:remove_const, :IOSInternal)
      rescue => e
      end
    end

    if Calabash.const_defined?(:Device)
      Calabash::Device.send(:class_variable_set, :@@default, nil)
    end

    if Calabash.const_defined?(:Application)
      Calabash::Device.send(:class_variable_set, :@@default, nil)
    end
  end
end

