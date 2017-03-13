#!/bin/sh
set -ex
# show available schemes
# xcodebuild -list -project ./BridgeSDK.xcodeproj
# run on merge to master or on a tag
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  fastlane doc
  exit $?
fi
