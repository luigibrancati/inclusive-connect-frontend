#!/bin/sh
rm -rf ./installers
mkdir ./installers
# Generate the icons if not already generated
echo "Generate icons"
flutter pub get
dart run flutter_launcher_icons
# Build apks
echo "Build APK"
flutter build apk --release
mv ./build/app/outputs/apk/release/app-release.apk ./installers/inclusive_connect.apk
echo "APK created: ./installers/inclusive_connect.apk"
# Build ipa
# echo "Build IPA"
# flutter build ios --no-codesign
# mkdir ./Payload
# cp -r ./build/ios/iphoneos/Runner.app Payload/
# zip -r ./installers/inclusive_connect.ipa Payload
# rm -rf ./Payload
# echo "Unsigned IPA created: ./installers/inclusive_connect.ipa"
# # Build web
# echo "Build Web"
# flutter build web --release
# mv ./build/web ./installers/inclusive_connect_web/
# echo "Web build created: ./installers/inclusive_connect_web"
