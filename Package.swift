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
        .target(name: "Devlibs",dependencies: []),
        .testTarget(name: "DevlibsTests",dependencies: ["Devlibs"]),
    ]
)
