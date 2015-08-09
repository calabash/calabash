| master  | develop | [versioning](VERSIONING.md) | [license](LICENSE) | [contributing](CONTRIBUTING.md)|
|---------|---------|-----------------------------|--------------------|--------------------------------|
|[![Build Status](https://travis-ci.org/calabash/calabash.svg?branch=master)](https://travis-ci.org/calabash/calabash)| [![Build Status](https://travis-ci.org/calabash/calabash.svg?branch=develop)](https://travis-ci.org/calabash/calabash)| [![GitHub version](https://badge.fury.io/gh/calabash%2Fcalabash.svg)](http://badge.fury.io/gh/calabash%2Fcalabash) |[![License](https://img.shields.io/badge/licence-Eclipse-blue.svg)](http://opensource.org/licenses/EPL-1.0) | [![Contributing](https://img.shields.io/badge/contrib-gitflow-orange.svg)](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/)|

## Calabash

Automated Acceptance Testing for Mobile Apps

## Initial workflow

**TL;DR**

```
$ cd calabash
$ ./copy_repos.sh
$ ./changing_old_files.sh
```

Before Calabash is ready to be released, the old gems will exist outside version control. To make a change run the script `copy_repos.sh`. This will copy the Android and iOS repositories and extract them as files in the directory `old`. Then execute `changing_old_files.sh`. This script will move old files into their new directories. To make changes to "old files" e.g. move them, add your steps to `changing_old_files.sh` and execute it. To make code changes to old files, change them locally first to ensure they work. Then copy the change to the branch `united` on either iOS or Android. Commit the changes and push them upstream. `copy_repos.sh` will always download the newest files.

## Rake

**TODO** Release instructions for Android and iOS.

```
$ rake -T
rake android:build     # Build the Android test server
rake build             # Build calabash-1.9.9.pre2.gem into the pkg directory
rake ctags             # Generate ctags in ./git/tags
rake install           # Build and install calabash-1.9.9.pre2.gem into system gems
rake release           # Create tag v1.9.9.pre2 and build and push calabash-1.9.9.pre2.gem to Rubygems
rake spec              # Run RSpec code examples
rake unit              # Run RSpec code examples
rake yard              # Generate YARD Documentation
rake yard:publish      # Generate and publish docs
```

## Testing

### rspec

```
$ be rake unit # All unit tests.
$ be rake spec # All tests.  Launches iOS Simulators, etc.
$ be guard     # Run unit tests as you develop.
```

### Cucumber Android

**NOTE** If you find you cannot launch on Android, be sure you run the
`copy\_repos` and `changing\_old\_files.sh` script.

```
$ bundle update
$ rake android:build
$ cd cucumber/android
$ be calabash resign ../../spec/resources/android/xtc-android-sample.apk
$ be calabash build ../../spec/resources/android/xtc-android-sample.apk
$ be cucumber
```

### Cucumber iOS

See `cucumber/ios/README.md`.

