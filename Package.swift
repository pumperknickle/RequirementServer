// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "RequirementServer",
    platforms: [
       .macOS(.v10_15)
        
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.5.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/mattpolzin/VaporOpenAPI.git", .exact("0.0.14")),
        .package(url: "https://github.com/mattpolzin/OpenAPIReflection.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/pumperknickle/RQTFoundation.git", from: "0.1.1"),
        .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "RQTFoundation", package: "RQTFoundation"),
                .product(name: "VaporOpenAPI", package: "VaporOpenAPI"),
                .product(name: "OpenAPIReflection", package: "OpenAPIReflection"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "PythonKit", package: "PythonKit"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
