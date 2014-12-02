echo "Deleting old files"
rm -rf old
rm -f android.zip
rm -f ios.zip
rm -rf calabash-android-united
rm -rf calabash-ios-united

echo "Downloading android files"
curl --silent -L -o united.zip https://codeload.github.com/calabash/calabash-android/zip/united
mv united.zip android.zip
echo "Downloading ios files"
curl --silent -L -o united.zip https://codeload.github.com/calabash/calabash-ios/zip/united
mv united.zip ios.zip

echo "Creating directories"
mkdir -p old/android
mkdir -p old/ios

echo "Unzipping android files"
unzip android.zip
echo "Unzipping ios files"
unzip ios.zip

echo "Moving android files"
mv calabash-android-united/* old/android

echo "Moving ios files"
mv calabash-ios-united/* old/ios

rm -f android.zip
rm -f ios.zip
rm -rf calabash-android-united
rm -rf calabash-ios-united
