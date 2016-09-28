require 'fileutils'

After("@cleanup_tmp_dir") do
  FileUtils.remove_entry(@dir)
  Dir.chdir(@pwd)
end