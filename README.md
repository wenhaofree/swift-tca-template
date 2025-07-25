# TCA Template

A comprehensive iOS application template built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

English | [中文](README-zh.md)

## 🚀 Overview

This template provides a complete, production-ready foundation for building iOS applications using TCA (The Composable Architecture). It includes authentication flows, modular architecture, comprehensive testing, and development tools to accelerate your iOS development process.

### Key Features

- ✅ **Complete Authentication System** - Login + Two-Factor Authentication
- ✅ **Modular Architecture** - Independent, testable feature modules
- ✅ **Standard Navigation** - Tab-based navigation with Home + Profile
- ✅ **Comprehensive Testing** - Unit tests, integration tests, and TCA TestStore
- ✅ **Development Tools** - Code generation scripts and automation
- ✅ **Modern SwiftUI** - Latest SwiftUI patterns and navigation APIs
- ✅ **Dependency Injection** - Testable architecture with mock support

### Technical Highlights
* **Swift 5.9+** with latest language features
* **iOS 15.0+** minimum deployment target (updated for compatibility)
* **SwiftUI-first** with modern navigation APIs
* **Comprehensive testing** with XCTest and TCA TestStore
* **Modular package structure** for independent feature development

## 📁 Project Structure

```
tca-template/
├── 📱 App/                          # iOS application entry point
│   ├── TcaTemplateApp.swift         # Main app entry
│   ├── RootView.swift               # Root view
│   └── Assets.xcassets              # App assets
├── 📦 tca-template/                 # Swift Package modules
│   ├── Package.swift               # Package configuration
│   ├── Sources/                     # Source code modules
│   │   ├── AppCore/                 # App core logic
│   │   ├── AppSwiftUI/              # App UI layer
│   │   ├── 🔐 AuthenticationClient/ # Authentication client interface
│   │   ├── AuthenticationClientLive/ # Authentication client implementation
│   │   ├── 🌐 NetworkClient/        # Network client interface
│   │   ├── NetworkClientLive/       # Network client implementation
│   │   ├── 🎨 CommonUI/             # Common UI components
│   │   ├── 🏠 HomeCore/             # Home feature core logic
│   │   ├── HomeSwiftUI/             # Home feature UI
│   │   ├── 👤 ProfileCore/          # Profile feature core logic
│   │   ├── ProfileSwiftUI/          # Profile feature UI
│   │   ├── 🔑 LoginCore/            # Login feature core logic
│   │   ├── LoginSwiftUI/            # Login feature UI
│   │   ├── 🔒 TwoFactorCore/        # Two-factor auth core logic
│   │   └── TwoFactorSwiftUI/        # Two-factor auth UI
│   └── Tests/                       # Test files
│       ├── AppCoreTests/            # App core tests
│       ├── HomeCoreTests/           # Home feature tests
│       ├── ProfileCoreTests/        # Profile feature tests
│       ├── LoginCoreTests/          # Login feature tests
│       └── TwoFactorCoreTests/      # Two-factor auth tests
├── 🛠️ Scripts/                      # Development tools
│   ├── generate-feature.sh         # Feature module generator
│   ├── rename-project.sh            # Project rename tool
│   ├── run-tests.sh                 # Test runner script
│   └── setup-dev.sh                 # Development setup
├── 📚 docs/                         # Documentation
│   ├── architecture.md             # Architecture guide
│   ├── feature-development.md      # Feature development guide
│   └── 系统说明.md                  # Chinese documentation
├── 🔧 tca-template.xcodeproj        # Xcode project file
└── 📖 README.md                     # Project documentation
```

## 🛠 Quick Start

### Requirements
- **iOS**: 15.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **macOS**: 13.0+

### 1. Clone and Setup
```bash
git clone <repository-url>
cd tca-template
```

### 2. Setup Development Environment
```bash
chmod +x Scripts/setup-dev.sh
./Scripts/setup-dev.sh
```

### 3. Build Project
```bash
# Using Swift Package Manager
cd tca-template
swift build
swift test

# Or open Xcode project
open tca-template.xcodeproj
```

### 4. Run Application
- Select `tca-template` scheme
- Choose target device/simulator
- Press `Cmd+R` to build and run

### 5. Rename Project (Optional)
```bash
./Scripts/rename-project.sh "YourAppName"
```

## 📚 Usage Guide

### 🔧 Development Tools

#### Generate New Feature Module
```bash
./Scripts/generate-feature.sh "Settings"
```

Automatically generates a complete feature module including:
- `SettingsCore/` - Business logic module
- `SettingsSwiftUI/` - UI components module  
- `SettingsCoreTests/` - Test module
- Package.swift configuration updates

#### Run Tests
```bash
# Run all tests
./Scripts/run-tests.sh

# Run specific module tests
swift test --filter HomeCoreTests

# Generate test coverage report
swift test --enable-code-coverage
```

#### Rename Project
```bash
./Scripts/rename-project.sh "MyAwesomeApp"
```

### 📦 Adding Dependencies

Use Swift Package Manager to add external dependencies:
```swift
// In Package.swift
dependencies: [
  .package(url: "https://github.com/example/package", from: "1.0.0")
]
```

### 🏗️ Feature Development Workflow

1. **Generate Feature Module**: Use scripts to generate boilerplate code
2. **Implement Business Logic**: Define State, Action, Reducer in Core module
3. **Build UI**: Implement views in SwiftUI module
4. **Write Tests**: Ensure functionality correctness
5. **Integrate to App**: Add navigation logic in AppCore

## 🏗️ Architecture Overview

### Core Principles

1. **Unidirectional Data Flow**: All state changes follow a single direction
2. **Immutable State**: State is read-only and updated through reducers
3. **Testable Design**: Every component is easily testable
4. **Modular Structure**: Features are independent and composable
5. **Dependency Injection**: All dependencies are injectable and mockable

### Module Types

| Module Type | Responsibility | Examples |
|-------------|----------------|----------|
| **Core Modules** | Business logic, state management, data flow | HomeCore, ProfileCore |
| **SwiftUI Modules** | UI views and components | HomeSwiftUI, CommonUI |
| **Client Modules** | External service interfaces | NetworkClient, AuthenticationClient |
| **Live Modules** | Concrete client implementations | NetworkClientLive, AuthenticationClientLive |

### Key Components

- **Reducer**: Handles state mutations and side effects
- **Store**: Holds state and dispatches actions
- **View**: Renders UI based on state
- **Client**: Manages external dependencies

### Data Flow Architecture
```
Action → Reducer → State → View
   ↑                        ↓
Effect ←←←←←←←←←←←←←←←←←←←←←←←
```

## 🧪 Testing Strategy

- ✅ **Unit Tests**: Test reducers and business logic
- ✅ **State Tests**: Verify state change correctness
- ✅ **Effect Tests**: Test async operations and network requests
- ✅ **Integration Tests**: Test feature module interactions

## 📖 Best Practices

1. **Keep Reducers Pure**: No side effects in reducer logic
2. **Use Dependency Injection**: Mock all external dependencies
3. **Test-Driven Development**: Write tests first for new features
4. **Modular Design**: Keep feature modules independent
5. **State Normalization**: Avoid nested state structures

## 🔧 Development Tools

| Script | Function | Usage |
|--------|----------|-------|
| `generate-feature.sh` | Generate new feature module | `./Scripts/generate-feature.sh FeatureName` |
| `rename-project.sh` | Rename entire project | `./Scripts/rename-project.sh NewName` |
| `setup-dev.sh` | Setup development environment | `./Scripts/setup-dev.sh` |
| `run-tests.sh` | Run test suite | `./Scripts/run-tests.sh` |

## 📚 Documentation

- [📖 Chinese Documentation](docs/系统说明.md) - Complete project documentation in Chinese
- [🏗️ Architecture Guide](docs/architecture.md) - Architecture patterns explained
- [🔧 Feature Development](docs/feature-development.md) - Development guide
- [TCA Official Documentation](https://pointfreeco.github.io/swift-composable-architecture/)

## 🎯 Feature Modules

### ✅ Implemented Features
- **Authentication System**: Login + Two-Factor Authentication
- **Home Module**: Content display and search functionality
- **Profile Module**: User information management
- **Common Components**: Reusable UI component library
- **Network Layer**: Unified network request handling

### 🔄 Extension Examples
```bash
# Generate Settings feature module
./Scripts/generate-feature.sh Settings

# Generate Notifications feature module
./Scripts/generate-feature.sh Notifications
```

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

### Code Standards
- Follow Swift API Design Guidelines
- Use SwiftLint for code checking
- Write clear comments and documentation
- Maintain test coverage > 80%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Point-Free](https://www.pointfree.co/) for creating TCA
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) community

---

**Happy Coding! 🚀**
