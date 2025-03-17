// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VoltaserveCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "VoltaserveCore",
            targets: ["VoltaserveCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/warrenm/GLTFKit2.git", from: "0.5.11")
    ],
    targets: [
        .target(
            name: "VoltaserveCore",
            dependencies: ["GLTFKit2"],
            path: "Sources"
        ),
        .testTarget(
            name: "VoltaserveTests",
            dependencies: ["VoltaserveCore"],
            path: "Tests",
            resources: [.process("Resources")]
        ),
    ]
)
