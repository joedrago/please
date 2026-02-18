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
        .target(
            name: "ObjCExceptionCatcher",
            path: "Sources/ObjCExceptionCatcher",
            publicHeadersPath: "include"
        ),
        .executableTarget(
            name: "Please",
            dependencies: ["KeyboardShortcuts", "ObjCExceptionCatcher"],
            path: "Sources/Please",
            exclude: ["Resources/Info.plist", "Resources/AppIcon.icns"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
