## Gem Developer How To

These instructions are for calabash developers.

These are not instructions for how to use the Calabash BDD framework.

## Testing

### rspec

If you are writing a new feature or updating an existing one, test it with
rspec.

```
$ cd calabash
$ be rake spec
```

#### Guard

Requires MacOS Growl - available in the AppStore.

```
$ bundle exec guard  start --no-interactions
```

## CI

* https://travis-ci.org/calabash/calabash
* https://travis-ci.org/calabash/run_loop
* https://travis-ci.org/calabash/calabash-ios-server
* Calabash iOS toolchain testing - http://ci.endoftheworl.de:8080/

## Releasing

### Create the release branch

```
$ git co develop
$ git pull
$ git checkout -b release/<next version> develop
```

No more features can be added.  All in-progress features and un-merged
pull-requests must wait for the next release.

You can, and should, make changes to the documentation.  You can bump the gem
 version and the minimum server version.

***You may not touch the gemspec.***  If you need to update a dependency, like
run-loop, do so before making the release and make sure the change makes it
through CI which will ensure the gemspec change is compatible with the XTC.

### Create a pull request for the release branch

Do this very soon after you make the release branch to notify the team that you
are planning a release.

```
$ git push -u origin release/<next version>
```

The pull-request should be made against the ***master*** branch.

Again, no more features can be added to this pull request.  Only changes to
documentation are allowed.  You can bump the gem version or change the minimum
server version.  _That's it._
