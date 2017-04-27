#!/bin/sh
set -ex
# show available schemes
# xcodebuild -list -project ./BridgeSDK.xcodeproj
cp BridgeAdminCredentials.plist ../BridgeAdminCredentials.plist
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    bundle exec fastlane doc scheme:"BridgeSDK"
    bundle exec fastlane test scheme:"BridgeSDK" only_testing:"BridgeSDKTests"
fi
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
    bundle exec fastlane doc scheme:"BridgeSDK"
    bundle exec fastlane test scheme:"BridgeSDK"
fi
exit $?
