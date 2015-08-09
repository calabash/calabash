require 'calabash/android'
require 'calabash/ios'

platform = ENV['PLATFORM']

# This example does not interact with an application. Therefore we simply
# set the default device to some unusable device instance.

class StubAndroidDevice < Calabash::Android::Device
  def initialize
  end
end

class StubIOSDevice < Calabash::IOS::Device
  def initialize
  end
end

case platform
  when 'android'
    require 'calabash/android'
    Calabash.default_device = StubAndroidDevice.new
    World(Calabash::Android)
  when 'ios'
    require 'calabash/ios'
    Calabash.default_device = StubIOSDevice.new
    World(Calabash::IOS)
  else
    message = if platform.nil? || platform.empty?
                'No platform given'
              else
                "Invalid platform '#{platform}'. Expected 'android' or 'ios'"
              end

    failure_messages =
        [
            'ERROR! Unable to start the cucumber test:',
            message,
            "Use the profile 'android' or 'ios'"
        ]

    Calabash::Logger.error(failure_messages.join("\n"))
    exit(1)
end

# For this example we are not really using the Calabash methods.
# This is not part of the example
module Calabash
  module Android
    def _enter_text_in(view, text)
      q = Calabash::Query.new(view)
      _example_print "Entering '#{text}' into \"#{q.send(:formatted_as_string)}\""
    end

    def tap(view)
      q = Calabash::Query.new(view)
      _example_print "Tapping \"#{q.send(:formatted_as_string)}\""
    end
  end

  module IOS
    def _enter_text_in(view, text)
      q = Calabash::Query.new(view)
      _example_print "Entering '#{text}' into \"#{q.send(:formatted_as_string)}\""
    end

    def tap(view)
      q = Calabash::Query.new(view)
      _example_print "Tapping \"#{q.send(:formatted_as_string)}\""
    end
  end
end

def _example_print(message)
  $stdout.puts "#{Calabash::Color.green(message)}"
end