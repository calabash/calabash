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