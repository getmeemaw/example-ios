// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cmd",
    platforms: [
        SupportedPlatform.macOS(.v11)
    ],
    dependencies: [
        // .package(path: "/Users/marceaulecomte/Documents/GitHub/meemaw/client/ios/meemaw-ios"), // dev
        .package(url: "https://github.com/getmeemaw/meemaw-ios", from: "1.2.0"),
        .package(url: "https://github.com/argentlabs/web3.swift", from: "1.1.0")
    ],
    targets: [
        .executableTarget(
            name: "cmd",
            dependencies: ["meemaw-ios", "web3.swift"]
        ),
    ]
)
