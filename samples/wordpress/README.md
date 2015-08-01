## Calabash Cross Platform Example

This project demonstrates how to write cross-platform Cucumber tests
with Calabash.

### Calabash Android

Connect an Android device via USB.  Make sure it is on the same network
as your computer.

```
$ bundle
$ bundle exec resign features/prebuild/wordpress_android.apk

# Run the cucumbers.
$ bundle exec calabash run features/prebuilt/wordpress_android.apk

# You can also use cucumber directly.
$ bundle exec cucumber -p android
```

To start a console:

```
$ bundle exec calabash console features/prebuilt/wordpress_android.apk
```

If you have mutliple Android device connected, you must specify which
device you want to test on.

```
# List the connected devices.
$ adb devices

# The device serial number.
$ CAL_DEVICE_ID=4<snip>9 bundle exec calabash run ...
```

### Calabash iOS

```
$ bundle

# Run the cucumbers.
$ bundle exec calabash run features/prebuilt/wordpress_ios.app

# You can also use cucumber directly.
$ bundle exec cucumber -p ios
```

To start a console:

```
$ bundle exec calabash console features/prebuilt/wordpress_ios.apk
```

To choose a different simulator to run the tests on, use the
`CAL_DEVICE_ID` variable.

```
# List the available simulators
$ xcrun instruments -s devices

# Use either the marketing name.
$ CAL_DEVICE="iPhone 6 Plus (8.4 Simulator)" bundle exec calabash run ...

# Or the simulator UDID.  Your UDIDs will be different!
$ CAL_DEVICE=AFD41B4D-AAB8-4FFD-A80D-7B32DE8EC01C bundle exec calabash run ...
```

