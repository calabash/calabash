require 'fileutils'
require 'tmpdir'
require 'pry'

def open_tmp_dir
  @dir = Dir.mktmpdir
  @pwd = Dir.pwd
  Dir.chdir(@dir)
end

def spawn_process_expect_exit_code(*args)
  begin
    FileUtils.touch('stdout')

    pid = Process.spawn(*args, out: 'stdout', err: 'stdout', chdir: Dir.pwd)
    Process.wait(pid)

    begin
      expect($?.exitstatus).to eq(0)
      output = File.read('stdout')
    rescue Exception => e
      puts "\n"
      puts "Output:\n"
      puts File.read('stdout')
      raise e
    end
  ensure
    File.delete('stdout') if File.exist?('stdout')
  end

  output
end

def gem_home
  "./gems:#{`gem environment gemdir`}"
end

def gem_path
  "./gems:#{`gem environment gempath`}"
end

Given(/^I am using bundler (.*) and have a Gemfile targeting Calabash$/) do |version|
  open_tmp_dir
  FileUtils.mkdir('gems')

  if version == 'latest'
    version = `gem list ^bundler$ --remote`.match(/bundler\ \((.*)\)/).captures.first
  end

  @version = version

  spawn_process_expect_exit_code({'BUNDLE_GEMFILE' => nil, 'GEM_HOME' => './gems', 'GEM_PATH' => './gems'},
                                 'gem', 'install', 'bundler', '--version', version)

  File.open('Gemfile', 'w+') do |file|
    file.puts "source \"https://www.rubygems.org\""
    file.puts ""
    file.puts "gem 'calabash', path: '#{File.join(@pwd, '../../../')}'"
  end
end

When(/^I run Calabash with bundle exec$/) do
  @output = spawn_process_expect_exit_code({'BUNDLE_GEMFILE' => nil,
                                            'BUNDLE_BIN_PATH' => nil,
                                            'RUBYLIB' => nil,
                                            'GEM_HOME' => gem_home, 'GEM_PATH' => gem_path},
                                           'ruby', '-S', 'bundler', "_#{@version}_", 'exec', 'calabash', 'used-bundler')
end

Then(/^Calabash should work and detect that we are running using Bundler$/) do
  expect(@output.chomp).to eq('true')
end
