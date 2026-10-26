// swift-tools-version: 6.4
// Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.

import PackageDescription

let package = Package(
    name: "KaizoshaUIKit",
    platforms: [.iOS(.v27)],
    products: [.library(name: "KaizoshaUIKit", targets: ["KaizoshaUIKit"])],
    targets: [
        .target(name: "KaizoshaUIKit", resources: [.process("Branding/Resources")]),
        .testTarget(name: "KaizoshaUIKitTests", dependencies: ["KaizoshaUIKit"])
    ],
    swiftLanguageModes: [.v6]
)
