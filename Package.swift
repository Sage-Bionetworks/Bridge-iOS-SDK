// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgeSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BridgeSDK",
            targets: ["BridgeSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "OpenSSL", url: "https://github.com/Sage-Bionetworks/CMSSupport.git", from: "1.1.1")
    ],
    targets: [
        .binaryTarget(name: "BridgeSDK",
                      path: "Output/BridgeSDK.xcframework"),
    ]
)
