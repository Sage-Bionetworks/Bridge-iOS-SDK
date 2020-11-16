rm -rf ./libOpenSSLBuilds/OpenSSL.xcframework
xcodebuild -create-xcframework \
    -library ./libOpenSSLBuilds/Release-iphoneos/bitcode/libOpenSSL.a \
    -headers ./libOpenSSLBuilds/Release-iphoneos/bitcode/OpenSSL \
    -library ./libOpenSSLBuilds/Release-iphonesimulator/marker/libOpenSSL.a \
    -headers ./libOpenSSLBuilds/Release-iphonesimulator/marker/OpenSSL \
    -output ./libOpenSSLBuilds/OpenSSL.xcframework
