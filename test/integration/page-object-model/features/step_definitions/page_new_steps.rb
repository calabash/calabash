And(/^Calabash is targeting an (Android|iOS|Unknown) platform$/) do |platform|
  class CalabashMethods
    def android?
      false
    end

    def ios?
      false
    end
  end

  if platform == "Android"
    class CalabashMethods
      def android?
        true
      end
    end
  elsif platform == "iOS"
    class CalabashMethods
      def ios?
        true
      end
    end
  end
end

When(/^the user instantiates the page using new$/) do
  # noinspection RubyModifiedFrozenObject
  begin
    @state[:page_instance] = @state[:page_class].new
  rescue => e
    @state[:error] = e
  end
end

Then(/^the user gets an instance of that particular page regardless of the platform$/) do
  expect(@state[:page_instance].class).to eq(@state[:page_class])
end


Then(/^Calabash raises an error stating it cannot detect the current platform$/) do
  expect(@state[:error]).not_to be_nil
  expect(@state[:error].message).to start_with("Unable to instantiate ")
end