// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cancellor",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "Cancellor",
            targets: ["Cancellor"]),
    ],
    targets: [
        .target(
            name: "Cancellor",
            dependencies: []),
        .testTarget(
            name: "CancellorTests",
            dependencies: ["Cancellor"]),
    ]
)
