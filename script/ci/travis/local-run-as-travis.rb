#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'ci-helpers'))

working_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))

env_vars = {'TRAVIS' => '1'}

Dir.chdir working_dir do
  do_system('script/ci/travis/install-gem-ci.rb',
            {:env_vars => env_vars})

  do_system('bundle exec rake spec',
            {:env_vars => env_vars})
end
