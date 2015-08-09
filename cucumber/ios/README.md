## Cucumber iOS

Features that demonstrate and test Calabash on iOS.

**TODO** It would be nice to have a public build server.

### Preparing

You must build the apps from sources.

```
$ cd cucumber/ios
$ bundle
$ be rake install_apps
```

You only need to run these rake tasks once.

If you want to use different binaries, drop them into
`cucumber/ios/binaries`.

To ensure you have the most recent sources for the apps:

```
$ be rake clean
```

#### Testing on Physical Devices

Testing against physical devices requires that you have ideviceinstaller
installed.

```
$ be rake install_ipas
```

If you have multiple Developer accounts, you might need to set the
`CODE_SIGN_IDENTITY` variable when you are building the ipas.

```
$ CODE_SIGN_IDENTITY="iPhone Developer: Joshua Moody (8QXXXXX9F)" be rake ensure_ipas
```

### Testing

See the `config/cucumber.yml` for defined profiles.

The Gemfile pins the calabash gem to `:path => '../../'`.

```
$ bundle
$ be cucumber             # Against the default simulator
$ be cucumber -p device   # Against a device.  See ./config/cucumber.yml
```


