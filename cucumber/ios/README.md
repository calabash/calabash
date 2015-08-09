## Cucumber iOS

Features that demonstrate and test Calabash on iOS.

### Preparing

To avoid checking apps and ipas into git, you must build the
apps from source.

**TODO** It would be nice to have a public build server.

Use the following rake tasks to build and install the apps and ipas
required for testing.

```
$ cd cucumber/ios
$ bundle
$ be rake ensure_apps
$ be rake ensure_ipas # Only if you need to test on physical devices.
```

You only need to run these rake tasks once.

If you want to use different binaries, drop them into
`cucumber/ios/binaries`.

### Testing

See the `config/cucumber.yml` for defined profiles.

The Gemfile pins the calabash gem to `:path => '../../'`.

```
$ bundle
$ be cucumber
```

Testing against physical devices requires that you have ideviceinstaller
installed.

