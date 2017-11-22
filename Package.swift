// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MandrillProvider",
    products: [
    	.library(name: "MandrillProvider", targets: ["MandrillProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
    	.target(name: "MandrillProvider", dependencies: ["Vapor"]),
    ]
)
