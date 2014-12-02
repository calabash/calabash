[![GitHub version](https://badge.fury.io/gh/calabash%2Fcalabash.svg)](http://badge.fury.io/gh/calabash%2Fcalabash) [![License](https://go-shields.herokuapp.com/license-Eclipse-blue.png)](http://opensource.org/licenses/EPL-1.0) [![Build Status](https://travis-ci.org/calabash/calabash.svg?branch=develop)](https://travis-ci.org/calabash/calabash-ios)

## Calabash

Automated Acceptance Testing for Mobile Apps

## Initial workflow

Before Calabash is ready to be released, the old gems will exist outside version control. To make a change run the script `copy_repos.sh`. This will copy the Android and iOS repositories and extract them as files in the directory `old`. Then execute `changing_old_files.sh`. This script will move old files into their new directories. To make changes to "old files" e.g. move them, add your steps to `changing_old_files.sh` and execute it. To make code changes to old files, change them locally first to ensure they work. Then copy the change to the branch `united` on either iOS or Android. Commit the changes and push them upstream. `copy_repos.sh` will always download the newest files.
