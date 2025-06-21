// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VoltaserveTouch",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "VoltaserveTouch",
            targets: ["VoltaserveTouch"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kouprlabs/voltaserve-core.git", branch: "main"),
        .package(url: "https://github.com/warrenm/GLTFKit2.git", from: "0.5.11"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.2"),
    ],
    targets: [
        .target(
            name: "VoltaserveTouch",
            dependencies: [
                .product(name: "VoltaserveCore", package: "voltaserve-core"),
                "GLTFKit2",
                "Kingfisher",
            ],
            path: "Sources"
        )
    ]
)
