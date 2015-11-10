Given(/^I am targeting an (.*) device$/) do |os|
  if os.downcase == 'android'
    Calabash.default_device = FakeAndroidDevice.new
  elsif os.downcase == 'ios'
    Calabash.default_device = FakeIOSDevice.new
  else
    raise "Unknown os '#{os}'"
  end
end

When(/^I instantiate "([^"]*)"$/) do |page|
  clz = eval(page)
  @page = page(clz)
end

When(/^I try to instantiate "([^"]*)"$/) do |page|
  clz = eval(page)

  begin
    @page = page(clz)
  rescue => e
    @error = e
  end
end

Then(/^the page should be (.*) "([^"]*)"$/) do |os, page|
  if os.downcase == 'android'
    mod = Android
  elsif os.downcase == 'ios'
    mod = IOS
  else
    raise "Unknown os '#{os}'"
  end

  calabash_self = get_calabash_self

  page_class = Calabash.recursive_const_get("#{mod.to_s}::#{page}")
  expect(@page.instance_variable_get(:@world)).to eq(calabash_self)
  expect(@page.class).to eq(page_class)
end

When(/^I instantiate an (.*) page "([^"]*)"$/) do |os, page|
  if os.downcase == 'android'
    mod = Android
  elsif os.downcase == 'ios'
    mod = IOS
  else
    raise "Unknown os '#{os}'"
  end

  clz = mod.const_get(page.to_sym)

  begin
    page(clz)
  rescue => e
    @error = e
  end
end

Then(/^I should get an error, telling me no such (.*) page exists$/) do |os|
  if os.downcase == 'android'
    expected_error = RuntimeError.new("No such page defined 'Android::Android::MyPage'")
  elsif os.downcase == 'ios'
    expected_error = RuntimeError.new("No such page defined 'IOS::Android::MyPage'")
  else
    raise "Unknown os '#{os}'"
  end

  expect(@error.message).to eq(expected_error.message)
  expect(@error.class).to eq(expected_error.class)
end

Then(/^I should get an error, telling me "(.*)" does not include Calabash::(.*)$/) do |page_name, os|
  os_name = if os == 'ios'
              'IOS'
            elsif os == 'Android'
              'Android'
            end

  full_page_name = if os_name == 'IOS'
                     full_page_name = "IOS::#{page_name}"
                   elsif os_name == 'Android'
                     full_page_name = "Android::#{page_name}"
                   end

  expect(@error.message).to eq("Page '#{full_page_name}' does not include Calabash::#{os_name}")
end

Then(/^I should not get an error$/) do
  expect(@error).to eq(nil)
end

Then(/^I should get an error, telling me (.*) "([^"]*)" includes both Calabash iOS and Calabash Android$/) do |os, page_name|
  os_name = if os == 'ios'
              'IOS'
            elsif os == 'Android'
              'Android'
            end

  full_page_name = if os_name == 'IOS'
                     full_page_name = "IOS::#{page_name}"
                   elsif os_name == 'Android'
                     full_page_name = "Android::#{page_name}"
                   end

  expect(@error.message).to eq("Page '#{full_page_name}' includes both Calabash::Android and Calabash::IOS")
end
