// swift-tools-version: 6.4
// Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.

import PackageDescription

let package = Package(
    name: "KaizoshaInterfaceKit",
    platforms: [.iOS(.v26)],
    products: [.library(name: "KaizoshaInterfaceKit", targets: ["KaizoshaInterfaceKit"])],
    targets: [
        .target(name: "KaizoshaInterfaceKit", resources: [.process("Branding/Resources")]),
        .testTarget(name: "KaizoshaInterfaceKitTests", dependencies: ["KaizoshaInterfaceKit"])
    ],
    swiftLanguageModes: [.v6]
)
