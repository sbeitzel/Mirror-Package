// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mirror-Package",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.2")
    ],
    targets: [
        .executableTarget(
            name: "Mirror-Package",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)
