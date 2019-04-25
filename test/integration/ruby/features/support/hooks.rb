require 'fileutils'

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
  end
end

After("@store_require_errors") do
  module Kernel
    alias_method :require, :cal_old_require
    alias_method :load, :cal_old_load
  end
end

Before("@store_require_errors") do
  module Kernel
    alias_method :cal_old_require, :require
    alias_method :cal_old_load, :load

    def require(name)
      begin
        cal_old_require(name)
      rescue Exception => e
        @rescue_exception = e
      end
    end

    def load(file)
      begin
        cal_old_load(file)
      rescue Exception => e
        @rescue_exception = e
      end
    end
  end
end

After("@cleanup_tmp_dir") do
  FileUtils.remove_entry(@dir)
  Dir.chdir(@pwd)
end
