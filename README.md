# TCA Template - Swift Composable Architecture Scaffold

A comprehensive, production-ready template for building iOS applications using Swift Composable Architecture (TCA). This template provides a solid foundation with best practices, modular architecture, and essential features that most iOS apps need.

## 🚀 Features

### Architecture & Design Patterns
* **Modular Architecture**: Highly modularized design with clear separation of concerns
* **TCA Best Practices**: Implements all TCA patterns and conventions
* **Dependency Injection**: Clean dependency management with protocol-based abstractions
* **State-Driven Navigation**: Complete navigation flows driven by application state
* **Cross-Platform Support**: Shared business logic between SwiftUI and UIKit

### Core Functionality
* **Authentication Flow**: Complete login system with two-factor authentication
* **Navigation Management**: Multi-step navigation flows with state restoration
* **Network Layer**: Robust networking with proper error handling
* **Testing Infrastructure**: Comprehensive test suite with unit, integration, and UI tests
* **Development Tools**: Scripts and utilities for rapid development

### Technical Highlights
* **Swift 6.0** with latest language features
* **iOS 13.0+** minimum deployment target
* **SwiftUI-first** with UIKit fallback support
* **Comprehensive testing** with XCTest and TCA TestStore
* **Modular package structure** for independent feature development

## 📁 Project Structure

```
TCA-Template/
├── App/                          # Main application target
│   ├── TcaTemplateApp.swift     # App entry point
│   ├── RootView.swift           # Root view controller
│   └── Assets.xcassets          # App assets
├── tca-template/                # Swift Package with modular architecture
│   ├── Package.swift           # Package configuration
│   ├── Sources/                 # Source modules
│   │   ├── AppCore/            # Main app coordinator
│   │   ├── AppSwiftUI/         # Main app UI
│   │   ├── AuthenticationClient/    # Auth service interface
│   │   ├── AuthenticationClientLive/ # Auth implementation
│   │   ├── LoginCore/          # Login business logic
│   │   ├── LoginSwiftUI/       # Login UI components
│   │   ├── CommonUI/           # Shared UI components
│   │   └── NetworkClient/      # Network layer
│   └── Tests/                  # Test modules
├── docs/                       # Documentation
└── Scripts/                    # Development tools
```

## 🛠 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/your-org/tca-template.git
cd tca-template
```

### 2. Rename Project (Optional)
```bash
./Scripts/rename-project.sh "YourAppName"
```

### 3. Open in Xcode
```bash
open tca-template.xcodeproj
```

### 4. Build and Run
- Select the `TcaTemplateApp` scheme
- Choose your target device/simulator
- Press `Cmd+R` to build and run

## 📚 Usage Guide

### Creating New Features

1. **Generate Feature Module**
```bash
./Scripts/generate-feature.sh "FeatureName"
```

This creates:
- `FeatureNameCore/` - Business logic module
- `FeatureNameSwiftUI/` - UI components module
- `FeatureNameTests/` - Test module

2. **Add to Navigation**
Update `AppCore.swift` to include your new feature in the app flow.

### Adding Dependencies

Use Swift Package Manager for external dependencies:
```swift
// In Package.swift
dependencies: [
  .package(url: "https://github.com/example/package", from: "1.0.0")
]
```

### Testing

Run all tests:
```bash
swift test
```

Run specific module tests:
```bash
swift test --filter LoginCoreTests
```

## 🏗 Architecture Overview

### Core Principles

1. **Unidirectional Data Flow**: All state changes flow in one direction
2. **Immutable State**: State is read-only and updated through reducers
3. **Testable by Design**: Every component is easily testable
4. **Modular Structure**: Features are isolated and composable
5. **Dependency Injection**: All dependencies are injected and mockable

### Module Types

- **Core Modules**: Business logic, state management, and data flow
- **UI Modules**: SwiftUI views and UIKit components
- **Client Modules**: External service interfaces and implementations
- **Shared Modules**: Common utilities and components

### Key Components

- **Reducer**: Handles state mutations and side effects
- **Store**: Holds state and dispatches actions
- **View**: Renders UI based on state
- **Client**: Manages external dependencies

## 🧪 Testing Strategy

- **Unit Tests**: Test individual reducers and business logic
- **Integration Tests**: Test feature interactions
- **UI Tests**: Test user flows and interface behavior
- **Snapshot Tests**: Ensure UI consistency across changes

## 📖 Best Practices

1. **Keep Reducers Pure**: No side effects in reducer logic
2. **Use Dependency Injection**: Mock all external dependencies
3. **Write Tests First**: TDD approach for new features
4. **Modular Design**: Keep features independent
5. **State Normalization**: Avoid nested state when possible

## 🔧 Development Tools

- `Scripts/generate-feature.sh` - Generate new feature modules
- `Scripts/rename-project.sh` - Rename the entire project
- `Scripts/setup-dev.sh` - Setup development environment
- `Scripts/run-tests.sh` - Run comprehensive test suite

## 📄 Documentation

- [TCA Official Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Project Architecture Guide](docs/architecture.md)
- [Feature Development Guide](docs/feature-development.md)
- [Testing Guide](docs/testing.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Point-Free](https://www.pointfree.co/) for creating TCA
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) community
