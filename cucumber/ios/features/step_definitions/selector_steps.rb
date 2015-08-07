module CalSmoke
  module Selectors

    def call_selector(array_or_symbol)
      query("view marked:'controls page'", array_or_symbol)
    end

    def returned_from_selector(array_or_symbol)
      result = call_selector(array_or_symbol)
      if result.empty?
        raise "Expected call to '#{array_or_symbol}' to return at least one value"
      end
      result.first
    end

    def expect_selector_truthy(array_or_symbol)
      res = call_selector(array_or_symbol)
      expect(res.empty?).to be_falsey
      expect(res.first).to be == 1
    end
  end
end

World(CalSmoke::Selectors)

When(/^I call an unknown selector on a view$/) do
  result = query("view marked:'controls page'", :unknownSelector)
  if result.empty?
    raise "Expected a query match for \"view marked:'controls page'\""
  end
  @received_back_from_selector = result.first
end

Then(/^I expect to receive back "(.*?)"$/) do |expected|
  expect(@received_back_from_selector).to be == expected
end

When(/^I call a method that references the matched view$/) do
  args = [{stringFromMethodWithSelf:'__self__'}]
  @received_back_from_selector = returned_from_selector(args)
end

Then(/^the view alarm property is off$/) do
  result = query("view marked:'controls page'", :alarm, :isOn)
  if result.empty?
    raise "Expected query match for \"view marked:'controls page'\""
  end
  expect(result.first).to be == 0
end

And(/^I can turn the alarm on$/) do
  result = query("view marked:'controls page'", :alarm, [{setIsOn:1}])
  if result.empty?
    raise "Expected query match for \"view marked:'controls page'\""
  end

  result = query("view marked:'controls page'", :alarm, :isOn)
  if result.empty?
    raise "Expected query match for \"view marked:'controls page'\""
  end

  expect(result.first).to be == 1
end

Then(/^I call selector with pointer argument$/) do
  arg = [{takesPointer:'a string'}]
  expect_selector_truthy(arg)
end

Then(/^I call selector with (unsigned int|int) argument$/) do |signed|
  if signed == 'int'
    arg = [{takesInt:-1}];
  else
    arg = [{takesUnsignedInt:1}];
  end
  expect_selector_truthy(arg)
end

Then(/^I call selector with (unsigned short|short) argument$/) do |signed|
  if signed == 'short'
    arg = [{takesShort:-1}];
  else
    arg = [{takesUnsignedShort:1}];
  end
  expect_selector_truthy(arg)
end

Then(/^I call selector with (unsigned long|long) argument$/) do |signed|
  if signed == 'long'
    arg = [{takesLong:-1}];
  else
    arg = [{takesUnsignedLong:1}];
  end
  expect_selector_truthy(arg)
end

Then(/^I call selector with (unsigned long long|long long) argument$/) do |signed|
  if signed == 'long long'
    arg = [{takesLongLong:-1}];
  else
    arg = [{takesUnsignedLongLong:1}];
  end
  expect_selector_truthy(arg)
end

Then(/^I call selector with float argument$/) do
  arg = [{takesFloat:0.1}]
  expect_selector_truthy(arg)
end

Then(/^I call selector with (long double|double) argument$/) do |signed|
  if signed == 'double'
    arg = [{takesDouble:0.1}];
  else
    arg = [{takesLongDouble:Math::PI}];
  end
  expect_selector_truthy(arg)
end

Then(/^I call selector with (unsigned char|char) argument$/) do |signed|
  if signed == 'char'
    # Passed a string
    arg = [{takesChar:'a'}]
    expect_selector_truthy(arg)

    # Passed a number
    arg = [{takesChar:-22}]
    expect_selector_truthy(arg)
  else
    # Passed a string
    arg = [{takesUnsignedChar:'a'}]
    expect_selector_truthy(arg)

    # Passed a number
    arg = [{takesUnsignedChar:22}]
    expect_selector_truthy(arg)
  end
end

Then(/^I call selector with BOOL argument$/) do
  # true/false
  arg = [{takesBOOL:true}]
  expect_selector_truthy(arg)

  arg = [{takesBOOL:false}]
  expect_selector_truthy(arg)

  # YES/NO
  arg = [{takesBOOL:1}]
  expect_selector_truthy(arg)

  arg = [{takesBOOL:0}]
  expect_selector_truthy(arg)
end

Then(/I call selector with c string argument$/) do
  arg = [{takesCString:'a c string'}]
  expect_selector_truthy(arg)
end

Then(/I call selector with (point|rect) argument$/) do |type|
  if type == 'point'
    point = {x:5.0, y:10.2}
    arg = [{takesPoint:point}]
  else
    rect = {x:5, y:10, width:44, height:44}
    arg = [{takesRect:rect}]
  end
  expect_selector_truthy(arg)
end

Then(/^I call a selector that returns void$/) do
  #expect(returned_from_selector(:returnsVoid)).to be == '<VOID>'
  expect(returned_from_selector(:returnsVoid)).to be == nil
end

Then(/^I call a selector that returns a pointer$/) do
  expect(returned_from_selector(:returnsPointer)).to be == 'a pointer'
end

Then(/^I call a selector that returns an? (unsigned char|char)$/) do |signed|
  if signed[/unsigned/, 0]
    result = returned_from_selector(:returnsUnsignedChar)
    expected = 97 # ASCII code for 'a'
  else
    result = returned_from_selector(:returnsChar)
    expected = -22
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns a c string$/) do
  expect(returned_from_selector(:returnsCString)).to be == 'c string'
end

Then(/^I call a selector that returns a (BOOL|bool)$/) do |boolean|
  if boolean == 'BOOL'
    result = returned_from_selector(:returnsBOOL)
  else
    result = returned_from_selector(:returnsBool)
  end
  expect(result).to be == 1
end

Then(/^I call a selector that returns an? (unsigned int|int)$/) do |signed|
  if signed[/unsigned/, 0]
    result = returned_from_selector(:returnsUnsignedInt)
    expected = 3
  else
    result = returned_from_selector(:returnsInt)
    expected = -3
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns an? (unsigned short|short)$/) do |signed|
  if signed[/unsigned/, 0]
    result = returned_from_selector(:returnsUnsignedShort)
    expected = 2
  else
    result = returned_from_selector(:returnsShort)
    expected = -2
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns a (long double|double)$/) do |double|
  if double[/long/, 0]
    result = returned_from_selector(:returnsLongDouble)
    expected = 0.55
  else
    result = returned_from_selector(:returnsDouble)
    expected = 0.5
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns a float$/) do
  expect(returned_from_selector(:returnsFloat)).to be == 3.14
end

Then(/^I call a selector that returns an? (unsigned long|long)$/) do |signed|
  if signed[/unsigned/, 0]
    result = returned_from_selector(:returnsUnsignedLong)
    expected = 4
  else
    result = returned_from_selector(:returnsLong)
    expected = -4
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns an? (unsigned long long|long long)$/) do |signed|
  if signed[/unsigned/, 0]
    result = returned_from_selector(:returnsUnsignedLongLong)
    expected = 5
  else
    result = returned_from_selector(:returnsLongLong)
    expected = -5
  end
  expect(result).to be == expected
end

Then(/^I call a selector that returns a point$/) do
  hash = {'X' => 0, 'Y' => 0,
          'description' => 'NSPoint: {0, 0}'}
  expect(returned_from_selector(:returnsPoint)).to be == hash
end

Then(/^I call a selector that returns a rect$/) do
  hash = {"Width" => 0, "Height" => 0, "X" => 0, "Y" => 0,
          "description" => "NSRect: {{0, 0}, {0, 0}}"}
  expect(returned_from_selector(:returnsRect)).to be == hash
end

Then(/^I call a selector that returns a CalSmokeAlarm struct$/) do
  expect(returned_from_selector(:returnSmokeAlarm)).to be_a_kind_of String
end

Then(/^I call a selector on a view that has 3 arguments$/) do
 args = ['a', 'b', 'c']
 array = [{selectorWithArg:args[0]},
          {arg:args[1]},
          {arg:args[2]}]
 result = returned_from_selector(array)
 ap result
 #expect(result).to be == args
end

Then(/^I make a chained call to a selector with 3 arguments$/) do
 args = ['a', 'b', 'c']
 array = [{selectorWithArg:args[0]},
          {arg:args[1]},
          {arg:args[2]}]
  result = query("view marked:'controls page'", :alarm, array)
  ap result
  #expect(result).to be == args
end

