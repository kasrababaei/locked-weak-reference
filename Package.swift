// swift-tools-version: 6.1

import Foundation
import PackageDescription
import CompilerPluginSupport

var package = Package(
    name: "locked-weak-reference",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "LockedWeakReference", targets: ["LockedWeakReference"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-latest"),
    ],
    targets: [
        Target.macro(
            name: "LockedWeakReferenceMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        Target.target(name: "LockedWeakReference", dependencies: ["LockedWeakReferenceMacro"]),
    ]
)

// Toggle this flag to include the client and test target for develop builds.
let isDevelop = false
if isDevelop {
    package.products.append(
        .executable(name: "LockedWeakReferenceClient", targets: ["LockedWeakReferenceClient"])
    )
    
    package.targets.append(
        contentsOf: [
            .executableTarget(name: "LockedWeakReferenceClient", dependencies: ["LockedWeakReference"]),
            .testTarget(
                name: "LockedWeakReferenceTests",
                dependencies: [
                    "LockedWeakReferenceMacro",
                    .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                ]
            )
        ]
    )
}
