// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navajo-Swift",
    products: [
        .library(
            name: "Navajo-Swift",
            targets: ["Navajo-Swift"]),
    ],
    targets: [
        .target(
            name: "Navajo-Swift",
            dependencies: [],
            path: "Source"),
    ]
)
