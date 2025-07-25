// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "tca-template",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "AppSwiftUI", targets: ["AppSwiftUI"]),
    .library(name: "AuthenticationClient", targets: ["AuthenticationClient"]),
    .library(name: "AuthenticationClientLive", targets: ["AuthenticationClientLive"]),
    .library(name: "GameCore", targets: ["GameCore"]),
    .library(name: "GameSwiftUI", targets: ["GameSwiftUI"]),
    .library(name: "LoginCore", targets: ["LoginCore"]),
    .library(name: "LoginSwiftUI", targets: ["LoginSwiftUI"]),
    .library(name: "NewGameCore", targets: ["NewGameCore"]),
    .library(name: "NewGameSwiftUI", targets: ["NewGameSwiftUI"]),
    .library(name: "TwoFactorCore", targets: ["TwoFactorCore"]),
    .library(name: "TwoFactorSwiftUI", targets: ["TwoFactorSwiftUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        "AuthenticationClient",
        "LoginCore",
        "NewGameCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        "LoginSwiftUI",
        "NewGameSwiftUI",
      ]
    ),

    .target(
      name: "AuthenticationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "AuthenticationClientLive",
      dependencies: ["AuthenticationClient"]
    ),

    .target(
      name: "GameCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "GameCoreTests",
      dependencies: ["GameCore"]
    ),
    .target(
      name: "GameSwiftUI",
      dependencies: ["GameCore"]
    ),

    .target(
      name: "LoginCore",
      dependencies: [
        "AuthenticationClient",
        "TwoFactorCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        "TwoFactorSwiftUI",
      ]
    ),

    .target(
      name: "NewGameCore",
      dependencies: [
        "GameCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "NewGameCoreTests",
      dependencies: ["NewGameCore"]
    ),
    .target(
      name: "NewGameSwiftUI",
      dependencies: [
        "GameSwiftUI",
        "NewGameCore",
      ]
    ),

    .target(
      name: "TwoFactorCore",
      dependencies: [
        "AuthenticationClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "TwoFactorCoreTests",
      dependencies: ["TwoFactorCore"]
    ),
    .target(
      name: "TwoFactorSwiftUI",
      dependencies: ["TwoFactorCore"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
