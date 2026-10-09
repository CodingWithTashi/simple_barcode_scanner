// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "simple_barcode_scanner",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(
            name: "simple-barcode-scanner",
            targets: ["simple_barcode_scanner"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "simple_barcode_scanner",
            dependencies: [
                .product(
                    name: "FlutterFramework",
                    package: "FlutterFramework"
                )
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
