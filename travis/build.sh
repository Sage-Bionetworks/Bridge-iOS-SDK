#!/bin/sh
set -ex
# show available schemes
# xcodebuild -list -project ./BridgeSDK.xcodeproj
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    bundle exec fastlane doc scheme:"BridgeSDK"
fi
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
    bundle exec fastlane doc scheme:"BridgeSDK"
    openssl aes-256-cbc -K $encrypted_d59c41fdd72b_key -iv $encrypted_d59c41fdd72b_iv -in BridgeAdminCredentials.plist.enc -out BridgeAdminCredentials.plist -d
    mv BridgeAdminCredentials.plist ..
    bundle exec fastlane test scheme:"BridgeSDK"
fi
exit $?
