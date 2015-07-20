module CalSmoke
  module Backdoor

    def log_app_crashed
      puts "\033[36m   App crashed.\033[0m"
    end
  end
end

World(CalSmoke::Backdoor)

And(/^I call backdoor with an unknown selector$/) do
  begin
    backdoor('unknownSelector:', '')
  rescue RuntimeError => e
    puts e
    @backdoor_raised_an_error = true
  end
end

Then(/^I should see a helpful error message$/) do
  expect(@backdoor_raised_an_error).to be == true
end

Then(/^the app should crash$/) do
  expect(@app_crashed).to be == true
end

And(/^I call backdoor on a method whose return type is void$/) do
  begin
    backdoor('backdoorWithVoidReturn:', 'argument');
  rescue Calabash::IOS::Routes::RouteError => _
    log_app_crashed
    @app_crashed = true
  end
end

And(/^I call backdoor on a method with no argument$/) do
  backdoor('backdoorWithArgument', nil)
end

And(/^I call backdoor on a method that returns an NSNumber$/) do
  @backdoor_argument = 'argument'
  @backdoor_result = backdoor('numberFromString:', @backdoor_argument)
end

And(/^I call backdoor on a method that returns a primitive$/) do
  begin
    backdoor('doesStateMatchStringArgument:', 'argument')
  rescue Calabash::IOS::Routes::RouteError
    log_app_crashed
    @app_crashed = true
  end
end

And(/^I call backdoor on a method that takes an NSString as an argument$/) do
  @backdoor_argument = 'argument'
  @backdoor_result = backdoor('stringByReturningString:', @backdoor_argument)
end

And(/^I call a valid backdoor but forget to include the trailing colon$/) do
  begin
    backdoor('stringByReturningString', 'argument')
  rescue ArgumentError => e
    @backdoor_raised_error = e
  end
end

Then(/backdoor will raise an argument error$/) do
  expect(@backdoor_raised_error).to be_a_kind_of(ArgumentError)
end

And(/^I call backdoor on a method that takes an NSDictionary as an argument$/) do
  @backdoor_argument = {'a' => 1, 'b' => 2, 'c' => 3}
  @backdoor_result = backdoor('stringByEncodingLengthOfDictionary:', @backdoor_argument)
end

And(/^I call backdoor on a method with NSArray return type$/) do
  @backdoor_argument = 'argument'
  @backdoor_result = backdoor('arrayByInsertingString:', @backdoor_argument)
end

And(/^I call backdoor on a method with NSDictionary return type$/) do
  @backdoor_argument = 'argument'
  @backdoor_result = backdoor('dictionaryByInsertingString:', 'argument')
end

And(/^I call backdoor on a method that takes a boolean argument$/) do
  @backdoor_argument = true
  @backdoor_result = backdoor('stringByEncodingBOOL:', @backdoor_argument)
end

And(/^I call backdoor on a method that takes an NSArray as an argument$/) do
  @backdoor_argument = [1, 2, 3]
  @backdoor_result = backdoor('numberWithCountOfArray:', @backdoor_argument)
end

And(/^I call backdoor on a method that takes an NSUInteger argument$/) do
  @backdoor_argument = 17
  @backdoor_result = backdoor('stringByEncodingNSUInteger:', @backdoor_argument)
end

And(/^I call backdoor on a method that takes a number argument$/) do
  @backdoor_argument = 10
  @backdoor_result = backdoor('stringByEncodingNumber:', @backdoor_argument)
end

And(/^I should get back that string$/) do
  expect(@backdoor_result).to be == @backdoor_argument
end

Then(/^I should get back the argument I passed$/) do
  expect(@backdoor_result).to be == @backdoor_argument
end

Then(/^I get back the length of the argument I passed$/) do
  expect(@backdoor_result).to be == @backdoor_argument.length
end

Then(/^I get back the argument I passed as a dictionary$/) do
  expect(@backdoor_result).to be == {@backdoor_argument => @backdoor_argument}
end

Then(/^I get back the argument I passed as an array$/) do
  expect(@backdoor_result).to be == [@backdoor_argument]
end

Then(/^I get back the length of that dictionary as a string$/) do
  expect(@backdoor_result).to be == '3'
end

Then(/^I won't get back that boolean as a string$/) do
  expect(@backdoor_result).not_to be == "#{@backdoor_argument}"
end

Then(/^I get back the length of the array as a number$/) do
  expect(@backdoor_result).to be == @backdoor_argument.length
end

Then(/^I get back that number as a string$/) do
  expect(@backdoor_result).to be == "#{@backdoor_argument}"
end

Then(/^I won't get back that integer as a string$/) do
  expect(@backdoor_result).not_to be == "#{@backdoor_argument}"
end
