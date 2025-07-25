# .gitignore 配置指南

本文档解释了项目中 `.gitignore` 文件的配置和各个部分的作用。

## 📋 概述

`.gitignore` 文件确保不必要的文件和目录不会被提交到版本控制系统中，保持仓库的清洁和安全。

## 🔧 主要配置部分

### 1. Xcode 相关文件

```gitignore
# 用户设置（每个开发者的个人配置）
xcuserdata/

# 构建产物和缓存
build/
DerivedData/
*.hmap

# 应用打包文件
*.ipa
*.dSYM.zip
*.dSYM
```

**说明**: 这些文件包含个人设置、构建缓存和编译产物，不应该被共享。

### 2. Swift Package Manager

```gitignore
.swiftpm/
.build/
*.swiftinterface
```

**说明**: SPM 的构建缓存和生成的接口文件，会自动重新生成。

### 3. 依赖管理工具

```gitignore
# CocoaPods
Pods/

# Carthage
Carthage/Build/

# Accio
Dependencies/
.accio/
```

**说明**: 第三方依赖的缓存和构建产物，通过包管理器重新安装即可。

### 4. 系统文件

```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
Desktop.ini
```

**说明**: 操作系统生成的元数据文件，对项目无用。

### 5. 开发工具

```gitignore
# IDE 配置
.vscode/
.idea/

# 编辑器临时文件
*.swp
*.swo
*~
```

**说明**: 各种编辑器和 IDE 的配置文件，通常包含个人偏好设置。

### 6. 安全敏感文件

```gitignore
# API 密钥和配置
.env
secrets.plist
APIKeys.plist

# 证书和描述文件
*.p12
*.mobileprovision
*.provisionprofile

# App Store Connect API 密钥
AuthKey_*.p8
```

**说明**: 包含敏感信息的文件，绝对不能提交到公共仓库。

### 7. 测试和分析文件

```gitignore
# 测试结果
test-results/
*.gcov
*.gcda
*.gcno

# 覆盖率报告
coverage/
*.coverage

# 性能分析数据
*.profdata
```

**说明**: 测试运行产生的临时文件和报告，可以重新生成。

### 8. 生成的代码

```gitignore
# 代码生成工具产生的文件
Generated/
*.generated.swift
R.generated.swift
```

**说明**: 由工具自动生成的代码文件，不应手动编辑或提交。

## 🎯 项目特定配置

### 应该包含的文件

- ✅ `.xcodeproj` 文件（项目配置）
- ✅ `Package.swift`（SPM 配置）
- ✅ `Package.resolved`（依赖版本锁定）
- ✅ 共享的 scheme 配置
- ✅ 源代码文件
- ✅ 资源文件（Assets.xcassets）
- ✅ 配置文件模板

### 应该忽略的文件

- ❌ 用户特定设置（xcuserdata）
- ❌ 构建产物（build/, DerivedData/）
- ❌ 临时文件和缓存
- ❌ 敏感信息（API 密钥、证书）
- ❌ 系统生成文件（.DS_Store）
- ❌ IDE 配置文件
- ❌ 测试报告和日志

## 🔍 验证配置

### 检查当前状态

```bash
# 查看未跟踪的文件
git status

# 查看被忽略的文件
git status --ignored

# 检查特定文件是否被忽略
git check-ignore path/to/file
```

### 清理已跟踪的文件

如果某些文件已经被跟踪但应该被忽略：

```bash
# 停止跟踪文件但保留本地副本
git rm --cached filename

# 停止跟踪目录
git rm -r --cached directory/

# 提交更改
git commit -m "Remove tracked files that should be ignored"
```

## 🛡️ 安全最佳实践

### 1. 敏感信息处理

- 使用环境变量或配置文件模板
- 将真实配置文件添加到 `.gitignore`
- 提供示例配置文件（如 `config.example.plist`）

### 2. 证书和密钥管理

- 绝不提交私钥或证书
- 使用 CI/CD 系统的安全存储
- 本地开发使用开发证书

### 3. API 密钥保护

```swift
// 使用配置文件
guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
      let keys = NSDictionary(contentsOfFile: path) else {
    fatalError("APIKeys.plist not found")
}
```

## 📝 维护建议

### 定期检查

- 定期审查 `.gitignore` 文件
- 检查是否有新的文件类型需要忽略
- 确保团队成员了解忽略规则

### 团队协作

- 在项目文档中说明 `.gitignore` 规则
- 统一团队的开发环境配置
- 及时更新忽略规则

### 工具推荐

- 使用 [gitignore.io](https://gitignore.io) 生成基础模板
- 使用 `git check-ignore` 调试忽略规则
- 定期运行 `git status --ignored` 检查

## 🔄 更新历史

- **v1.0**: 初始版本，包含基础 Swift/iOS 忽略规则
- **v1.1**: 添加 TCA 项目特定配置
- **v1.2**: 增强安全配置，添加更多工具支持

---

**注意**: 根据项目需求调整 `.gitignore` 配置，确保既不遗漏重要文件，也不包含不必要的文件。
