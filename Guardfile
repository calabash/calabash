notification :growl, sticky: false, priority: 0
logger level: :info

guard 'bundler' do
  watch('Gemfile')
end

guard :rspec, cmd: 'bundle exec rspec', failed_mode: :focus, all_after_pass: true, all_on_start: true do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }

end
