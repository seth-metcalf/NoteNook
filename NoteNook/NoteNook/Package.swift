// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NoteNook",
    platforms: [
        .macOS(.v16)
    ],
    products: [
        .executable(
            name: "NoteNook",
            targets: ["NoteNook"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed in the future
        // .package(url: "https://github.com/example/package.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "NoteNook",
            dependencies: [],
            path: "NoteNook/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency=complete")
            ]
        ),
        .testTarget(
            name: "NoteNookTests",
            dependencies: ["NoteNook"],
            path: "NoteNookTests"
        )
    ],
    swiftLanguageVersions: [.v6]
)
