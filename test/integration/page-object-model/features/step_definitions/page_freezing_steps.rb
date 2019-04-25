Given(/^a page that inherits from (Page|AbstractPage) with an initializer that tries to set a variable$/) do |page_type|
  # noinspection RubyModifiedFrozenObject
  @state[:page_class] = Class.new(Calabash.const_get(page_type.to_sym)) do
    def initialize
      @my_var = :foo
    end
  end
end

Then(/^Calabash fails because the page is frozen$/) do
  expect(@state[:error]).not_to be_nil
  expect(@state[:error].message).to start_with("can't modify frozen")
end

Given(/^a page that inherits from (Page|AbstractPage) with a method that tries to set a variable$/) do |page_type|
  # noinspection RubyModifiedFrozenObject
  @state[:page_class] = Class.new(Calabash.const_get(page_type.to_sym)) do
    def my_method
      @my_var = :foo
    end
  end
end

And(/^the method of the page is called$/) do
  begin
    @state[:page_instance].my_method
  rescue => e
    # noinspection RubyModifiedFrozenObject
    @state[:error] = e
  end
end

Given(/^a page that inherits from (Page|AbstractPage) that sets a static variable when it is loaded$/) do |page_type|
  # noinspection RubyModifiedFrozenObject
  @state[:page_class] = Class.new(Calabash.const_get(page_type.to_sym)) do
    @var = :foo

    class << self
      @var2 = :baz
    end
  end
end

Then(/^Calabash does not fail$/) do
  expect(@state[:error]).to be_nil
end
