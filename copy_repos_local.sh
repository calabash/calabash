echo "Deleting old files"
rm -rf old/android/*
rm -rf old/ios/*

cp -r $CALABASH_ANDROID_HOME/ old/android
cp -r $CALABASH_IOS_HOME/ old/ios
