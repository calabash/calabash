require 'calabash'

platform = ENV['PLATFORM']

unless platform
  application = Calabash::Application.default_from_environment

  if application.android_application?
    platform = 'android'
  elsif application.ios_application?
    platform = 'ios'
  else
    raise "Application '#{application}' is neither an Android app nor an iOS app"
  end
end

case platform
  when 'android'
    require 'calabash/android'

    Calabash::Android.setup_defaults!
  when 'ios'
    require 'calabash/ios'

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
            "Run cucumber with the ENV variable 'CAL_APP' set to the path of the application under test, or specify 'PLATFORM'"
        ]

    Calabash::Logger.error(failure_messages.join("\n"))
    exit(1)
end
