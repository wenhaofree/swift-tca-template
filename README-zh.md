# TCA 模板项目

一个基于 [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 构建 iOS 应用的完整模板脚手架。

[English](README.md) | 中文

## 🚀 快速开始

### 环境要求
- **iOS**: 15.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **macOS**: 13.0+

### 技术亮点
* **Swift 5.9+** 使用最新语言特性
* **iOS 15.0+** 最低部署目标（已更新兼容性）
* **SwiftUI 优先** 使用现代导航 API
* **全面测试** 使用 XCTest 和 TCA TestStore
* **模块化包结构** 支持独立功能开发

## 📁 项目结构

```
tca-template/
├── 📱 App/                          # iOS 应用入口
│   ├── TcaTemplateApp.swift         # 应用主入口
│   ├── RootView.swift               # 根视图
│   └── Assets.xcassets              # 应用资源
├── 📦 tca-template/                 # Swift Package 模块
│   ├── Package.swift               # 包配置文件
│   ├── Sources/                     # 源代码模块
│   │   ├── AppCore/                 # 应用核心逻辑
│   │   ├── AppSwiftUI/              # 应用 UI 层
│   │   ├── 🔐 AuthenticationClient/ # 认证客户端接口
│   │   ├── AuthenticationClientLive/ # 认证客户端实现
│   │   ├── 🌐 NetworkClient/        # 网络客户端接口
│   │   ├── NetworkClientLive/       # 网络客户端实现
│   │   ├── 🎨 CommonUI/             # 通用 UI 组件
│   │   ├── 🏠 HomeCore/             # 首页核心逻辑
│   │   ├── HomeSwiftUI/             # 首页 UI 实现
│   │   ├── 👤 ProfileCore/          # 个人资料核心逻辑
│   │   ├── ProfileSwiftUI/          # 个人资料 UI 实现
│   │   ├── 🔑 LoginCore/            # 登录核心逻辑
│   │   ├── LoginSwiftUI/            # 登录 UI 实现
│   │   ├── 🔒 TwoFactorCore/        # 双因素认证核心逻辑
│   │   └── TwoFactorSwiftUI/        # 双因素认证 UI 实现
│   └── Tests/                       # 测试文件
│       ├── AppCoreTests/            # 应用核心测试
│       ├── HomeCoreTests/           # 首页逻辑测试
│       ├── ProfileCoreTests/        # 个人资料测试
│       ├── LoginCoreTests/          # 登录逻辑测试
│       └── TwoFactorCoreTests/      # 双因素认证测试
├── 🛠️ Scripts/                      # 开发工具脚本
│   ├── generate-feature.sh         # 功能模块生成器
│   ├── rename-project.sh            # 项目重命名工具
│   ├── run-tests.sh                 # 测试运行脚本
│   └── setup-dev.sh                 # 开发环境设置
├── 📚 docs/                         # 文档目录
│   ├── architecture.md             # 架构说明
│   ├── feature-development.md      # 功能开发指南
│   └── 系统说明.md                  # 中文系统说明
├── 🔧 tca-template.xcodeproj        # Xcode 项目文件
└── 📖 README.md                     # 项目说明
```

## 🛠 快速开始

### 1. 克隆和设置
```bash
git clone <repository-url>
cd tca-template
```

### 2. 设置开发环境
```bash
chmod +x Scripts/setup-dev.sh
./Scripts/setup-dev.sh
```

### 3. 构建项目
```bash
# 使用 Swift Package Manager
cd tca-template
swift build
swift test

# 或者打开 Xcode 项目
open tca-template.xcodeproj
```

### 4. 运行应用
- 选择 `tca-template` scheme
- 选择目标设备/模拟器
- 按 `Cmd+R` 构建并运行

### 5. 重命名项目 (可选)
```bash
./Scripts/rename-project.sh "YourAppName"
```

## ✨ 主要功能

### 🔐 认证系统
- **登录流程**: 邮箱/密码认证
- **双因素认证**: 验证码确认
- **状态管理**: 登录状态持久化
- **错误处理**: 网络错误和验证错误

### 📱 应用界面
- **首页 (Home)**: 内容展示和搜索功能
- **个人资料 (Profile)**: 用户信息管理
- **Tab 导航**: 标准的底部标签导航

### 🎨 通用组件
- **LoadingButton**: 带加载状态的按钮
- **ErrorView**: 统一错误展示组件
- **SearchBar**: 搜索输入组件
- **TabView**: 标准标签导航

## 📚 使用指南

### 🔧 开发工具

#### 生成新功能模块
```bash
./Scripts/generate-feature.sh "Settings"
```

自动生成包含以下内容的完整功能模块：
- `SettingsCore/` - 业务逻辑模块
- `SettingsSwiftUI/` - UI 组件模块  
- `SettingsCoreTests/` - 测试模块
- Package.swift 配置更新

#### 运行测试
```bash
# 运行所有测试
./Scripts/run-tests.sh

# 运行特定模块测试
swift test --filter HomeCoreTests

# 生成测试覆盖率报告
swift test --enable-code-coverage
```

#### 项目重命名
```bash
./Scripts/rename-project.sh "MyAwesomeApp"
```

### 📦 添加依赖

使用 Swift Package Manager 添加外部依赖：
```swift
// 在 Package.swift 中
dependencies: [
  .package(url: "https://github.com/example/package", from: "1.0.0")
]
```

### 🏗️ 功能开发流程

1. **生成功能模块**: 使用脚本生成基础代码
2. **实现业务逻辑**: 在 Core 模块中定义 State、Action、Reducer
3. **构建 UI**: 在 SwiftUI 模块中实现视图
4. **编写测试**: 确保功能正确性
5. **集成到应用**: 在 AppCore 中添加导航逻辑

## 🏗️ 架构概述

### 核心原则

1. **单向数据流**: 所有状态变化都遵循单一方向
2. **不可变状态**: 状态只读，通过 Reducer 更新
3. **可测试设计**: 每个组件都易于测试
4. **模块化结构**: 功能独立且可组合
5. **依赖注入**: 所有依赖都可注入和模拟

### 模块类型

| 模块类型 | 职责 | 示例 |
|---------|------|------|
| **Core 模块** | 业务逻辑、状态管理、数据流 | HomeCore, ProfileCore |
| **SwiftUI 模块** | UI 视图和组件 | HomeSwiftUI, CommonUI |
| **Client 模块** | 外部服务接口和实现 | NetworkClient, AuthenticationClient |
| **Live 模块** | Client 的具体实现 | NetworkClientLive, AuthenticationClientLive |

### 关键组件

- **Reducer**: 处理状态变更和副作用
- **Store**: 保存状态并分发 Action
- **View**: 基于状态渲染 UI
- **Client**: 管理外部依赖

### 数据流架构
```
Action → Reducer → State → View
   ↑                        ↓
Effect ←←←←←←←←←←←←←←←←←←←←←←←
```

## 🧪 测试策略

- ✅ **单元测试**: 测试 Reducer 和业务逻辑
- ✅ **状态测试**: 验证状态变化的正确性
- ✅ **副作用测试**: 测试异步操作和网络请求
- ✅ **集成测试**: 测试功能模块间的交互

## 📖 最佳实践

1. **保持 Reducer 纯净**: Reducer 中不包含副作用
2. **使用依赖注入**: 模拟所有外部依赖
3. **测试驱动开发**: 为新功能优先编写测试
4. **模块化设计**: 保持功能模块独立
5. **状态规范化**: 避免嵌套状态结构

## 🔧 开发工具

| 脚本 | 功能 | 使用方法 |
|------|------|----------|
| `generate-feature.sh` | 生成新功能模块 | `./Scripts/generate-feature.sh FeatureName` |
| `rename-project.sh` | 重命名整个项目 | `./Scripts/rename-project.sh NewName` |
| `setup-dev.sh` | 设置开发环境 | `./Scripts/setup-dev.sh` |
| `run-tests.sh` | 运行测试套件 | `./Scripts/run-tests.sh` |

## 📚 文档资源

- [📖 中文系统说明](docs/系统说明.md) - 完整的项目文档
- [🏗️ 架构设计](docs/architecture.md) - 架构模式详解
- [🔧 功能开发](docs/feature-development.md) - 开发指南
- [TCA 官方文档](https://pointfreeco.github.io/swift-composable-architecture/)

## 🎯 功能模块

### ✅ 已实现功能
- **认证系统**: 登录 + 双因素认证
- **首页模块**: 内容展示和搜索
- **个人资料**: 用户信息管理
- **通用组件**: 可复用 UI 组件库
- **网络层**: 统一的网络请求处理

### 🔄 扩展示例
```bash
# 生成设置功能模块
./Scripts/generate-feature.sh Settings

# 生成通知功能模块  
./Scripts/generate-feature.sh Notifications
```

## 🤝 贡献指南

### 开发流程
1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

### 代码规范
- 遵循 Swift API 设计指南
- 使用 SwiftLint 进行代码检查
- 编写清晰的注释和文档
- 保持测试覆盖率 > 80%

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

---

**Happy Coding! 🚀**
