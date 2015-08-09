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

options =
      {
            cmd: 'bundle exec rspec',
            spec_paths: ['spec/lib'],
            failed_mode: :focus,
            all_after_pass: true,
            all_on_start: true
      }

guard(:rspec, options)  do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/calabash/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec/lib' }
  watch('spec/resources/ios/ios_resources.rb') { 'spec/lib' }
  watch('lib/calabash.rb') { 'spec/lib' }
  watch('lib/ios.rb') { 'spec/lib' }
  watch('lib/android.rb') { 'spec/lib' }
end
