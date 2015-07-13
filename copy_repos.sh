echo "Deleting old files"
rm -rf old
rm -f android.zip
rm -f ios.zip
rm -rf calabash-android-united
rm -rf calabash-ios-united

echo "Downloading android files"
curl --silent -L -o master.zip https://codeload.github.com/calabash/calabash-android/zip/master
mv master.zip android.zip

echo "Creating directories"
mkdir -p old/android

echo "Unzipping android files"
unzip android.zip

echo "Moving android files"
mv calabash-android-master/* old/android

rm -f android.zip
rm -rf calabash-android-master
