module Calabash
  module IOS

    require 'calabash/ios/device/runtime_attributes'
    require 'calabash/ios/device/routes/error'
    require 'calabash/ios/device/routes/response_parser'
    require 'calabash/ios/device/routes/handle_route_mixin'
    require 'calabash/ios/device/routes/map_route_mixin'
    require 'calabash/ios/device/routes/uia_route_mixin'
    require 'calabash/ios/device/routes/condition_route_mixin'
    require 'calabash/ios/device/routes/backdoor_route_mixin'
    require 'calabash/ios/device/routes/playback_route_mixin'
    require 'calabash/ios/device/gestures_mixin'
    require 'calabash/ios/device/physical_device_mixin'
    require 'calabash/ios/device/status_bar_mixin'
    require 'calabash/ios/device/rotation_mixin'
    require 'calabash/ios/device/keyboard_mixin'
    require 'calabash/ios/device/uia_keyboard_mixin'
    require 'calabash/ios/device/uia_mixin'
    require 'calabash/ios/device/ipad_1x_2x_mixin'
    require 'calabash/ios/device/device_implementation'

  end
end
