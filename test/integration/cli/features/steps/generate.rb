require 'fileutils'
require 'tmpdir'

def open_tmp_dir
  @dir = Dir.mktmpdir
  @pwd = Dir.pwd
  Dir.chdir(@dir)
end

def spawn_process_expect_exit_code(*args)
  begin
    FileUtils.touch('stdout')

    pid = Process.spawn(*args, out: 'stdout', err: 'stdout')
    Process.wait(pid)

    begin
      expect($?.exitstatus).to eq(0)
    rescue Exception => e
      puts "\n"
      puts "Output:\n"
      puts File.read('stdout')
      raise e
    end
  ensure
    File.delete('stdout') if File.exist?('stdout')
  end
end

def generate_cucumber
  `bundle exec calabash generate-cucumber`
  gemfile = File.read('Gemfile')
  gemfile.gsub!(/gem\ \'calabash\'\,\ \'(.*)\'/, "gem 'calabash', path: '#{File.join(@pwd, '/../../../')}'")
  File.open('Gemfile', 'w') {|file| file.puts gemfile }
  FileUtils.touch("app.apk")
  FileUtils.touch("app.ipa")
  require 'calabash/utility'
  require 'calabash/application'
  require 'calabash/android/application'
  require 'calabash/android/build'
  test_server = Calabash::Android::Build::TestServer.new('app.apk').path
  FileUtils.mkdir(File.dirname(test_server))
  FileUtils.touch(test_server)
end

def execute_command(command)
  if command == 'generate-cucumber'
    generate_cucumber
  else
    `bundle exec calabash #{command}`
  end
end

Given(/^I am in an empty working directory$/) do
  open_tmp_dir
end

When(/^I use the Calabash CLI command "(.*)"$/) do |command|
  execute_command(command)
end

Then(/^I have a basic Cucumber skeleton$/) do
  spawn_process_expect_exit_code({"BUNDLE_GEMFILE" => nil}, "bundle", "install")
  spawn_process_expect_exit_code({"BUNDLE_GEMFILE" => nil}, "bundle", "exec", "cucumber", "--dry-run")
end

Given(/^I have generated a Cucumber skeleton$/) do
  open_tmp_dir
  execute_command('generate-cucumber')
end

When(/^I run Cucumber with CAL_APP set to (.*)$/) do |app|
  env = File.read('features/support/env.rb')
  env.gsub!('Calabash::Android.setup_defaults!', '#Calabash::Android.setup_defaults!')
  env.gsub!('Calabash::IOS.setup_defaults!', '#Calabash::IOS.setup_defaults!')
  File.open('features/support/env.rb', 'w') {|file| file.puts env }

  File.open('features/support/stub.rb', 'w+') do |file|
    file.puts("def cal")
    file.puts("Stub.new")
    file.puts("end")
    file.puts("class Stub < BasicObject")
    file.puts("def method_missing(method, *args)")
    file.puts("method")
    file.puts("end")
    file.puts("end")
  end

  spawn_process_expect_exit_code({"BUNDLE_GEMFILE" => nil, "CAL_APP" => app}, "bundle", "exec", "cucumber")
end

Then(/^the auto generated skeleton runs with the (.*) platform$/) do |os|

end