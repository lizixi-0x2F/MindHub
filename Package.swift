// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MindHub",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .executable(
            name: "MindHub",
            targets: ["MindHub"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MindHub",
            dependencies: [],
            path: "MindHub",
            resources: [
                .process("Resources")
            ]
        ),
    ]
) 