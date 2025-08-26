// swift-tools-version: 6.1

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "locked-weak-reference",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "LockedWeakReference",
            targets: ["LockedWeakReference"]
        ),
        .executable(
            name: "LockedWeakReferenceClient",
            targets: ["LockedWeakReferenceClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "LockedWeakReferenceMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        .target(name: "LockedWeakReference", dependencies: ["LockedWeakReferenceMacro"]),

        .executableTarget(name: "LockedWeakReferenceClient", dependencies: ["LockedWeakReference"]),

        .testTarget(
            name: "LockedWeakReferenceTests",
            dependencies: [
                "LockedWeakReferenceMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
