#!/bin/sh
set -ex
# version from brew is borked, https://github.com/tomaz/appledoc/issues/596
# brew install appledoc
git clone git://github.com/tomaz/appledoc.git ~/appledoc
pushd ~/appledoc
./install-appledoc.sh -t ~/.appledoc
popd

