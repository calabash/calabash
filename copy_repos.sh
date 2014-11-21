echo "Deleting old files"
rm -rf old
rm -f android.zip
rm -f ios.zip
rm -rf calabash-android-master
rm -rf calabash-ios-master

echo "Downloading android files"
curl --silent -L -o master.zip https://codeload.github.com/calabash/calabash-android/zip/master
mv master.zip android.zip
echo "Downloading ios files"
curl --silent -L -o master.zip https://codeload.github.com/calabash/calabash-ios/zip/master
mv master.zip ios.zip

echo "Creating directories"
mkdir -p old/android
mkdir -p old/ios

echo "Unzipping android files"
unzip android.zip
echo "Unzipping ios files"
unzip ios.zip

echo "Moving android files"
mv calabash-android-master/* old/android

echo "Moving ios files"
mv calabash-ios-master/* old/ios

rm -f android.zip
rm -f ios.zip
rm -rf calabash-android-master
rm -rf calabash-ios-master
