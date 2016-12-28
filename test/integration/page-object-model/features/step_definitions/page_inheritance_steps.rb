Given(/^a user defined page that inherits from (Page|AbstractPage)$/) do |page_type|
  # noinspection RubyModifiedFrozenObject
  @state[:page_class] = Class.new(Calabash.const_get(page_type.to_sym)) do
  end
end

When(/^the user creates a new page that inherits from the user defined page$/) do
  # noinspection RubyModifiedFrozenObject
  begin
    @state[:page_instance] = Class.new(@state[:page_class]) do
    end
  rescue => e
    @state[:error] = e
  end
end

Then(/^Calabash raises an error stating that page inheritance is discouraged$/) do
  expect(@state[:error]).not_to be_nil
  expect(@state[:error].class).to eq(TypeError)
  expect(@state[:error].message).to match(/^.* cannot inherit from .*\. Can only inherit.*/)
end

When(/^the user creates a new page (Android|IOS) that inherits from the user defined page$/) do |platform|
  # We need a way of accessing the class using the class name
  Object.const_set(:StoredPage, @state[:page_class])

  begin
    if platform == 'Android'
      class StoredPage
        class Android
          def my_method; end
        end
      end
    elsif platform == 'IOS'
      class StoredPage
        class IOS
          def my_method; end
        end
      end
    end
  rescue => e
    # noinspection RubyModifiedFrozenObject
    @state[:error] = e
  ensure
    Object.send(:remove_const, :StoredPage)
  end
end

Then(/^Calabash does not raise an error$/) do
  expect(@state[:error]).to be_nil
end


When(/^the user creates a new page MySubPage that inherits from the user defined page$/) do
  # We need a way of accessing the class using the class name
  Object.const_set(:StoredPage, @state[:page_class])

  begin
    class StoredPage
      class MySubPage < StoredPage
      end
    end
  rescue => e
    # noinspection RubyModifiedFrozenObject
    @state[:error] = e
  ensure
    Object.send(:remove_const, :StoredPage)
  end
end


Then(/^the user gets an instance of that page specialized for (Android|iOS)$/) do |platform|
  subpage = if platform == "Android"
              @state[:page_class].const_get(:Android)
            elsif platform == "iOS"
              @state[:page_class].const_get(:IOS)
            end

  expect(@state[:page_instance].class).to eq(subpage)
end