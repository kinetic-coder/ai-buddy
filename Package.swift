// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIBuddy",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "AIBuddy", targets: ["AIBuddy"])],
    targets: [
        .executableTarget(name: "AIBuddy", path: "Sources/AIBuddy"),
        .testTarget(name: "AIBuddyTests", dependencies: ["AIBuddy"], path: "Tests/AIBuddyTests")
    ]
)
