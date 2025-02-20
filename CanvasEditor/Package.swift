// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CanvasEditor",
    platforms: [
        // Platforms specifies os version minimums. It does not limit which platforms are supported.
        .iOS(.v17),
        .macOS(.v12)  // The SDK does not support macOS, this satisfies SwiftLint requirements
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CanvasEditor",
            targets: ["CanvasEditor"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CanvasEditor",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CanvasEditorTests",
            dependencies: ["CanvasEditor"]
        ),
    ]
)
