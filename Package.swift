// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Bootpay",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Bootpay",
            targets: ["Bootpay"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Bootpay",
            dependencies: [],
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
