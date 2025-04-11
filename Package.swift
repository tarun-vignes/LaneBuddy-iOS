// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "LaneBuddy",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "LaneBuddy",
            targets: ["LaneBuddy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-native-ios.git", .upToNextMajor(from: "5.13.0")),
        .package(url: "https://github.com/maplibre/maplibre-navigation-ios.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "LaneBuddy",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-native-ios"),
                .product(name: "MapLibreNavigation", package: "maplibre-navigation-ios")
            ]),
        .testTarget(
            name: "LaneBuddyTests",
            dependencies: ["LaneBuddy"]),
    ]
)
