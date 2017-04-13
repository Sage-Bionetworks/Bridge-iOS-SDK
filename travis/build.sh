#!/bin/sh
set -ex
# show available schemes
# xcodebuild -list -project ./BridgeSDK.xcodeproj
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    bundle exec fastlane test scheme:"BridgeSDK"
elif [ "$TRAVIS_BRANCH" = "master" ]; then
    bundle exec fastlane test scheme:"BridgeSDK"
fi
if [ ! -z "$TRAVIS_TAG" ]; then
    bundle exec fastlane doc scheme:"BridgeSDK"
fi
exit $?
