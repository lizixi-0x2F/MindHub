// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MindHub",
    platforms: [.iOS(.v16)],
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