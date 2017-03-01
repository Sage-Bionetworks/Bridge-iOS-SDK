#!/bin/sh
set -ex
git clone https://github.com/Erin-Mounts/mogenerator.git
cd mogenerator && xcodebuild -scheme mogenerator
