#!/bin/sh
set -ex
# setup config file for integration tests
cp BridgeAdminCredentials.plist ../BridgeAdminCredentials.plist
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then     # on pull requests
    bundle exec fastlane doc scheme:"BridgeSDK"
    # secrets not available on PR builds so need to exclude integration tests
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"BridgeSDK" only_testing:"BridgeSDKTests"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    bundle exec fastlane doc scheme:"BridgeSDK"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"BridgeSDK" # run all tests
fi
exit $?
