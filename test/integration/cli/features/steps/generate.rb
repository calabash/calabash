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
  gemfile = File.read(File.join(@pwd, 'Gemfile'))
  gemfile.gsub!("path => '../../../'", "path => '#{File.join(@pwd, '/../../../')}'")
  File.open('Gemfile', 'w+') {|file| file.puts gemfile }
  Process.wait(Process.spawn({"BUNDLE_GEMFILE" => nil}, "bundle", "exec", "calabash", "generate-cucumber",
                             out: '/dev/null', err: '/dev/null'))

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
    Process.wait(Process.spawn({"BUNDLE_GEMFILE" => nil}, "bundle", "exec", "calabash", command,
                               out: '/dev/null', err: '/dev/null'))
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
  env.gsub!('Calabash::Android.setup_defaults!', 'Calabash.default_device = Calabash::Android::Device.allocate')
  env.gsub!('Calabash::IOS.setup_defaults!', 'Calabash.default_device = Calabash::IOS::Device.allocate')
  File.open('features/support/env.rb', 'w') {|file| file.puts env }

  File.open('features/support/stub.rb', 'w+') do |file|
    file.puts("$orig_cal = cal")
    file.puts("def cal")
    file.puts("Stub.new")
    file.puts("end")
    file.puts("class Stub < BasicObject")
    file.puts("def ios?")
    file.puts("$orig_cal.ios?")
    file.puts("end")
    file.puts("def android?")
    file.puts("$orig_cal.android?")
    file.puts("end")
    file.puts("def method_missing(method, *args)")
    file.puts("method")
    file.puts("end")
    file.puts("end")
  end

  File.delete("features/sample.feature")
  File.delete("features/step_definitions/sample_steps.rb")

  File.open('features/platform.feature', 'w+') do |file|
    file.puts("Feature: Platform")
    file.puts("Scenario: Display platform")
    file.puts("Then I display the platform")
  end

  File.open('features/step_definitions/platform.rb', 'w+') do |file|
    file.puts("Then(/^I display the platform$/) do")
    file.puts("File.open('platform', 'w+') do |file|")
    file.puts("file.puts(\"ios:\#{cal.ios?}\")")
    file.puts("file.puts(\"android:\#{cal.android?}\")")
    file.puts("end")
    file.puts("end")
  end

  spawn_process_expect_exit_code({"BUNDLE_GEMFILE" => nil, "CAL_APP" => app}, "bundle", "exec", "cucumber")
end

Then(/^the auto generated skeleton runs with the (.*) platform$/) do |os|
  Hash[File.read('platform').lines.map {|l| l.split(":")}].each do |k,v|
    if k.downcase == os.downcase
      expect(v.chomp).to eq("true")
    else
      expect(v.chomp).to eq("false")
    end
  end
end