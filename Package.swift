// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Devlibs",
    platforms: [
        .iOS(.v11), .macOS(.v10_12), .tvOS(.v11), .watchOS(.v4),
    ],
    products: [
        .library(name: "Devlibs", targets: ["Devlibs"]),
    ],
    targets: [
        .target(name: "Devlibs", dependencies: ["Devlibs-core", "Devlibs-graphics", "Devlibs-networking"]),
        .target(name: "Devlibs-core", dependencies: []),
        .target(name: "Devlibs-graphics", dependencies: ["Devlibs-core"]),
        .target(name: "Devlibs-networking", dependencies: ["Devlibs-core"]),
        .testTarget(name: "DevlibsTests", dependencies: ["Devlibs"]),
    ]
)
