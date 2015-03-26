require 'bundler/gem_tasks'
require File.join(File.dirname(__FILE__), 'build', 'build.rb')

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/lib/**{,/*/**}/*_spec.rb'
  end
rescue LoadError => _
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |_|
    # See .yardopts for options.
  end
rescue LoadError => _
end

namespace :android do
  task :ensure_files_exist do
    Calabash::Build::AndroidTestServer.ensure_test_server_exists
    Calabash::Build::AndroidTestServer.ensure_calabash_js_exists
  end

  task :build_test_server do
    Calabash::Build::AndroidTestServer.build_test_server
  end

  task :build => [:ensure_files_exist, :build_test_server] do
  end
end
