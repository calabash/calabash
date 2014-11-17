#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'ci-helpers'))

working_directory = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))

Dir.chdir working_directory do

  do_system('rake install',
            {:pass_msg => 'Successfully used rake to install the gem',
             :fail_msg => 'Could not install the gem with rake'})

end
