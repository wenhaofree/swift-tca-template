// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "tca-template",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    // MARK: - Core Application
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "AppSwiftUI", targets: ["AppSwiftUI"]),

    // MARK: - Authentication
    .library(name: "AuthenticationClient", targets: ["AuthenticationClient"]),
    .library(name: "AuthenticationClientLive", targets: ["AuthenticationClientLive"]),
    .library(name: "LoginCore", targets: ["LoginCore"]),
    .library(name: "LoginSwiftUI", targets: ["LoginSwiftUI"]),
    .library(name: "TwoFactorCore", targets: ["TwoFactorCore"]),
    .library(name: "TwoFactorSwiftUI", targets: ["TwoFactorSwiftUI"]),

    // MARK: - Common Modules
    .library(name: "CommonUI", targets: ["CommonUI"]),
    .library(name: "NetworkClient", targets: ["NetworkClient"]),
    .library(name: "NetworkClientLive", targets: ["NetworkClientLive"]),

    // MARK: - Feature Examples (Remove when creating new app)
    .library(name: "HomeCore", targets: ["HomeCore"]),
    .library(name: "HomeSwiftUI", targets: ["HomeSwiftUI"]),
    .library(name: "ProfileCore", targets: ["ProfileCore"]),
    .library(name: "ProfileSwiftUI", targets: ["ProfileSwiftUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.20.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "1.6.0"),
  ],
  targets: [
    // MARK: - Core Application
    .target(
      name: "AppCore",
      dependencies: [
        "AuthenticationClient",
        "LoginCore",
        "HomeCore",
        "ProfileCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "AppCoreTests",
      dependencies: ["AppCore"]
    ),
    .target(
      name: "AppSwiftUI",
      dependencies: [
        "AppCore",
        "CommonUI",
        "LoginSwiftUI",
        "HomeSwiftUI",
        "ProfileSwiftUI",
      ]
    ),

    // MARK: - Authentication
    .target(
      name: "AuthenticationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .target(
      name: "AuthenticationClientLive",
      dependencies: [
        "AuthenticationClient",
        "NetworkClient",
      ]
    ),

    // MARK: - Common Modules
    .target(
      name: "CommonUI",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .target(
      name: "NetworkClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .target(
      name: "NetworkClientLive",
      dependencies: ["NetworkClient"]
    ),

    .target(
      name: "LoginCore",
      dependencies: [
        "AuthenticationClient",
        "TwoFactorCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "LoginCoreTests",
      dependencies: ["LoginCore"]
    ),
    .target(
      name: "LoginSwiftUI",
      dependencies: [
        "LoginCore",
        "CommonUI",
        "TwoFactorSwiftUI",
      ]
    ),

    // MARK: - Feature Examples (Replace with your own features)
    .target(
      name: "HomeCore",
      dependencies: [
        "NetworkClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "HomeCoreTests",
      dependencies: ["HomeCore"]
    ),
    .target(
      name: "HomeSwiftUI",
      dependencies: [
        "HomeCore",
        "CommonUI",
      ]
    ),

    .target(
      name: "ProfileCore",
      dependencies: [
        "AuthenticationClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "ProfileCoreTests",
      dependencies: ["ProfileCore"]
    ),
    .target(
      name: "ProfileSwiftUI",
      dependencies: [
        "ProfileCore",
        "CommonUI",
      ]
    ),

    .target(
      name: "TwoFactorCore",
      dependencies: [
        "AuthenticationClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Perception", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "TwoFactorCoreTests",
      dependencies: ["TwoFactorCore"]
    ),
    .target(
      name: "TwoFactorSwiftUI",
      dependencies: [
        "TwoFactorCore",
        "CommonUI",
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
