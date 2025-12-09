// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Bootpay",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Bootpay",
            targets: ["Bootpay"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", from: "4.2.0"),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "5.1.1")
    ],
    targets: [
        .target(
            name: "Bootpay",
            dependencies: [
                "CryptoSwift",
                "ObjectMapper",
                "NVActivityIndicatorView"
            ],
            path: "Bootpay",
            exclude: ["Assets"],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
