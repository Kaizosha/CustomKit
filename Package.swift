// swift-tools-version: 6.4
// Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.

import PackageDescription

let package = Package(
    name: "CustomKit",
    platforms: [
        .iOS(.v27)
    ],
    products: [
        .library(name: "CustomKit", targets: ["CustomKit"])
    ],
    targets: [
        .target(name: "CustomKit"),
        .testTarget(
            name: "CustomKitTests",
            dependencies: ["CustomKit"]
        )
    ],
    swiftLanguageModes: [.v6]
)
