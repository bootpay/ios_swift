// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bootpay",
    platforms: [
        .macOS(.v12), .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Bootpay",
            targets: ["Bootpay"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.4.0")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", .upToNextMajor(from: "5.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Bootpay",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "ObjectMapper", package: "ObjectMapper"),
                .product(name: "NVActivityIndicatorView", package: "NVActivityIndicatorView"),
            ],
            path: "Bootpay/Classes"
        ),
    ]
)
