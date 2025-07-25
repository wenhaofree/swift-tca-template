# Xcode Preview 故障排除指南

本文档解释了如何解决 Xcode SwiftUI Preview 中常见的问题。

## 🚨 常见错误

### 错误信息：
```
Select a scheme that builds a target which contains the current file, 
or add this file to a target that is built by the current scheme.
```

## 🔍 问题分析

这个错误通常表示以下问题之一：

### 1. **文件不在任何 Target 中**
- 文件存在于文件系统中，但没有被添加到 Xcode 项目的任何 target
- Swift Package Manager 项目中，模块没有在 `Package.swift` 中定义

### 2. **模块依赖问题**
- 文件引用了不存在的模块
- 模块间的依赖关系配置错误

### 3. **Scheme 配置问题**
- 当前选择的 scheme 不包含该文件所属的 target
- Target 没有正确配置构建设置

## 🛠️ 解决方案

### 方案 1: 检查 Package.swift 配置

对于 Swift Package Manager 项目，确保所有模块都在 `Package.swift` 中正确定义：

```swift
// Package.swift
let package = Package(
  name: "your-package",
  products: [
    .library(name: "YourModule", targets: ["YourModule"]),
  ],
  targets: [
    .target(
      name: "YourModule",
      dependencies: [
        // 添加必要的依赖
      ]
    ),
  ]
)
```

### 方案 2: 清理遗留代码

如果发现有未使用的模块或文件：

```bash
# 删除不需要的模块目录
rm -rf Sources/UnusedModule

# 重新构建项目
swift build
```

### 方案 3: 验证模块依赖

检查文件顶部的 import 语句：

```swift
import ComposableArchitecture
import YourModule  // 确保这个模块存在且已定义
import SwiftUI
```

### 方案 4: 重新构建项目

```bash
# 清理构建缓存
rm -rf .build

# 重新构建
swift build

# 运行测试验证
swift test
```

## 🔧 预防措施

### 1. **保持 Package.swift 同步**
- 添加新模块时，立即更新 `Package.swift`
- 删除模块时，同时从 `Package.swift` 中移除

### 2. **使用脚本验证**
创建验证脚本检查项目一致性：

```bash
#!/bin/bash
# check-modules.sh

echo "检查模块一致性..."

# 检查 Sources 目录中的模块
for dir in Sources/*/; do
    module_name=$(basename "$dir")
    if ! grep -q "name: \"$module_name\"" Package.swift; then
        echo "警告: $module_name 模块未在 Package.swift 中定义"
    fi
done

# 构建测试
swift build && echo "✅ 构建成功"
```

### 3. **定期清理**
- 定期检查并删除未使用的代码
- 保持项目结构清洁
- 及时更新依赖关系

## 📋 检查清单

在遇到 Preview 问题时，按以下顺序检查：

- [ ] 文件是否在正确的模块目录中？
- [ ] 模块是否在 `Package.swift` 中定义？
- [ ] 所有 import 的模块是否存在？
- [ ] 项目是否能正常构建？(`swift build`)
- [ ] 测试是否通过？(`swift test`)
- [ ] Xcode 是否选择了正确的 scheme？

## 🎯 最佳实践

### 1. **模块命名规范**
```
Sources/
├── FeatureCore/          # 业务逻辑
├── FeatureSwiftUI/       # UI 组件
└── FeatureTests/         # 测试（在 Tests/ 目录下）
```

### 2. **依赖管理**
- Core 模块不依赖 SwiftUI 模块
- SwiftUI 模块依赖对应的 Core 模块
- 避免循环依赖

### 3. **Preview 最佳实践**
```swift
#Preview {
  NavigationView {
    YourView(
      store: Store(initialState: YourFeature.State()) {
        YourFeature()
      }
    )
  }
}
```

## 🔄 故障排除流程

1. **确认错误信息**
   - 记录完整的错误信息
   - 确定是哪个文件出现问题

2. **检查项目结构**
   - 验证文件位置
   - 检查 Package.swift 配置

3. **清理和重建**
   - 删除 .build 目录
   - 重新构建项目

4. **验证修复**
   - 运行 `swift build`
   - 运行 `swift test`
   - 尝试 Xcode Preview

## 📞 获取帮助

如果问题仍然存在：

1. 检查 [TCA 官方文档](https://pointfreeco.github.io/swift-composable-architecture/)
2. 查看项目的 `docs/` 目录中的其他文档
3. 运行项目提供的检查脚本

---

**记住**: 保持项目结构的一致性是避免这类问题的最佳方法！🚀
