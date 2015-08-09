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

desc 'Generate and publish docs'
namespace :yard do
  task :publish do
    # Obtain the publish script from a maintainer.
    sh 'script/docs/publish-calabash-docs.sh'
  end
end

desc 'Generate ctags in ./git/tags.'
task :ctags do
  sh 'rm -f .git/tags'
  excluded = [
    '--exclude=*.png',
    '--exclude=.screenshots',
    '--exclude=*screenshots*',
    '--exclude=reports',
    '--exclude=*.app',
    '--exclude=*.dSYM',
    '--exclude=*.ipa',
    '--exclude=*.zip',
    '--exclude=*.framework',
    '--exclude=.irb-history',
    '--exclude=.pry-history',
    '--exclude=.idea',
    '--exclude=*.plist',
    '--exclude=.gitignore',
    '--exclude=Gemfile.lock',
    '--exclude=Gemfile',
    '--exclude=docs',
    '--exclude=*.md',
    '--exclude=*.java',
    '--exclude=*.xml',
    '--exclude=cucumber/android/test_servers',
    '--exclude=android/test-server',
    '--exclude=lib/calabash/android/lib/calmd5',
    '--exclude=lib/calabash/ios/lib/recordings',
    '--exclude=cucumber/ios/binaries',
    '--exclude=.irbrc',
    '--exclude=.DS_Store'
  ]
  cmd = "ctags --tag-relative -V -f .git/tags -R #{excluded.join(' ')} --languages=ruby lib/ spec/ cucumber/"
  sh cmd
end

namespace :android do
  task :ensure_files_exist do
    Calabash::Build::AndroidTestServer.ensure_test_server_exists
    Calabash::Build::AndroidTestServer.ensure_calabash_js_exists
  end

  task :build_test_server do
    Calabash::Build::AndroidTestServer.build_test_server
  end

  task :build_native do
    `NDK_PROJECT_PATH='android/calmd5' $NDK_HOME/ndk-build`
    `rm -r lib/calabash/android/lib/calmd5`
    `mv android/calmd5/libs lib/calabash/android/lib/calmd5`
  end

  desc 'Build the Android test server.'
  task :build => [:ensure_files_exist, :build_test_server] do
  end
end

