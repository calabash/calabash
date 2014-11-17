require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => _
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |_|
    # See .yardopts for options.
  end
rescue LoadError => _
end
