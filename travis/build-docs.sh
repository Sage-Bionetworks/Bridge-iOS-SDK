#!/bin/sh
set -ex
# show available schemes
# xcodebuild -list -project ./BridgeSDK.xcodeproj
# run on merge to master or on a tag
if [ "$TRAVIS_BRANCH" = "master" -a "$TRAVIS_PULL_REQUEST" = "false" ] || [ -n "TRAVIS_TAG" ]; then
  fastlane doc
  exit $?
fi
