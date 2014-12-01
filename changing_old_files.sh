./calabash_git_mv.sh old/android/ruby-gem/test-server android/test-server
./calabash_git_commit.sh -m \"Move test-server from old projects to android directory\"

./calabash_git_mv.sh old/android/ruby-gem/lib/calabash-android/environment.rb lib/calabash/android/environment.rb
./calabash_git_commit.sh -m \"Move android environment file\"
