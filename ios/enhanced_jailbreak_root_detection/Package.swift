// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "enhanced_jailbreak_root_detection",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(
            name: "enhanced-jailbreak-root-detection",
            targets: ["enhanced_jailbreak_root_detection"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/securing/IOSSecuritySuite.git", from: "1.9.10")
    ],
    targets: [
        .target(
            name: "enhanced_jailbreak_root_detection",
            dependencies: [
                .product(name: "IOSSecuritySuite", package: "IOSSecuritySuite")
            ],
            resources: []
        )
    ]
)
