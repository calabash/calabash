require 'calabash'
require 'calabash/android/application'
require 'calabash/ios/application'

platform = ENV['PLATFORM']

unless platform
  application = Calabash::Application.default_from_environment

  if application.android_application?
    platform = 'android'
  elsif application.ios_application?
    platform = 'ios'
  else
    raise "Application '#{application}' is neither an Android app or an iOS app"
  end
end

case platform
  when 'android'
    require 'calabash/android'

    World(Calabash::Android)

    Calabash::Android.setup_defaults!
  when 'ios'
    require 'calabash/ios'

    World(Calabash::IOS)

    Calabash::IOS.setup_defaults!
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
            "Run cucumber with the ENV variable 'CAL_APP', or run cucumber using $ calabash run"
        ]

    Calabash::Logger.error(failure_messages.join("\n"))
    exit(1)
end
