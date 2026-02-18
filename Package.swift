// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Please",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Please",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources/Please",
            exclude: ["Resources/Info.plist"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
