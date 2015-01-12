notification :growl, sticky: false, priority: 0
logger level: :info
clearing :on

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

# Short-running examples should be placed in spec/lib
# Long-running examples and examples that steal the application focus
# (e.g. launch the simulator) should be placed in spec/integration.
guard :rspec, cmd: 'bundle exec rspec', spec_paths: ['spec/lib'] do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/calabash/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec/lib' }
end
