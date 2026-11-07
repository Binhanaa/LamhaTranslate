// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LamhaTranslate",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LamhaTranslate", targets: ["LamhaTranslate"])
    ],
    targets: [
        .executableTarget(
            name: "LamhaTranslate",
            path: "Sources/LamhaTranslate"
        )
    ]
)
