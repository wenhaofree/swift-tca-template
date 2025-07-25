# Feature Development Guide

This guide walks you through developing new features in the TCA Template, from initial planning to implementation and testing.

## 📋 Table of Contents

- [Planning a Feature](#planning-a-feature)
- [Generating Feature Modules](#generating-feature-modules)
- [Implementing Core Logic](#implementing-core-logic)
- [Building the UI](#building-the-ui)
- [Adding to Navigation](#adding-to-navigation)
- [Writing Tests](#writing-tests)
- [Best Practices](#best-practices)

## Planning a Feature

Before writing code, plan your feature thoroughly:

### 1. Define the Feature Scope

- What problem does this feature solve?
- What are the main user flows?
- What data does the feature need?
- What external services will it use?

### 2. Design the State

Identify what state your feature needs:

```swift
// Example: Settings feature
struct State {
  var user: User?
  var settings: AppSettings
  var isLoading: Bool
  var error: SettingsError?
  var isDarkModeEnabled: Bool
  var notificationsEnabled: Bool
}
```

### 3. Define Actions

List all possible user interactions and system events:

```swift
enum Action {
  case onAppear
  case toggleDarkMode
  case toggleNotifications
  case saveSettings
  case settingsSaved
  case errorOccurred(SettingsError)
}
```

### 4. Identify Dependencies

What external services does your feature need?

- Network requests
- Local storage
- System services (notifications, location, etc.)
- Other app features

## Generating Feature Modules

Use the provided script to generate the basic structure:

```bash
./Scripts/generate-feature.sh Settings
```

This creates:
- `SettingsCore/` - Business logic module
- `SettingsSwiftUI/` - UI components module  
- `SettingsCoreTests/` - Test module

### Manual Setup

If you prefer manual setup, create the following structure:

```
Sources/
├── SettingsCore/
│   └── SettingsCore.swift
├── SettingsSwiftUI/
│   └── SettingsView.swift
Tests/
└── SettingsCoreTests/
    └── SettingsCoreTests.swift
```

## Implementing Core Logic

### 1. Define the State

Start with your state definition:

```swift
@ObservableState
public struct State: Equatable {
  public var settings: AppSettings
  public var isLoading = false
  public var error: SettingsError?
  
  public init(settings: AppSettings = .default) {
    self.settings = settings
  }
}
```

### 2. Define Actions

Create comprehensive actions:

```swift
public enum Action: BindableAction, Sendable {
  case binding(BindingAction<State>)
  case onAppear
  case toggleDarkMode
  case toggleNotifications
  case saveSettings
  case settingsLoaded(AppSettings)
  case settingsSaved
  case errorOccurred(SettingsError)
}
```

### 3. Implement the Reducer

Handle all actions in your reducer:

```swift
public var body: some Reducer<State, Action> {
  BindingReducer()
  
  Reduce { state, action in
    switch action {
    case .binding:
      return .none
      
    case .onAppear:
      return .run { send in
        let settings = try await settingsClient.loadSettings()
        await send(.settingsLoaded(settings))
      } catch: { error, send in
        await send(.errorOccurred(.loadFailed(error.localizedDescription)))
      }
      
    case .toggleDarkMode:
      state.settings.isDarkModeEnabled.toggle()
      return .send(.saveSettings)
      
    case .saveSettings:
      state.isLoading = true
      return .run { [settings = state.settings] send in
        try await settingsClient.saveSettings(settings)
        await send(.settingsSaved)
      } catch: { error, send in
        await send(.errorOccurred(.saveFailed(error.localizedDescription)))
      }
      
    case let .settingsLoaded(settings):
      state.settings = settings
      return .none
      
    case .settingsSaved:
      state.isLoading = false
      return .none
      
    case let .errorOccurred(error):
      state.isLoading = false
      state.error = error
      return .none
    }
  }
}
```

### 4. Add Dependencies

Define and inject dependencies:

```swift
@Dependency(\.settingsClient) var settingsClient

// Define the client
@DependencyClient
public struct SettingsClient {
  public var loadSettings: () async throws -> AppSettings
  public var saveSettings: (AppSettings) async throws -> Void
}
```

## Building the UI

### 1. Create the Main View

Build your SwiftUI view:

```swift
public struct SettingsView: View {
  let store: StoreOf<Settings>
  
  public var body: some View {
    NavigationView {
      Group {
        if store.isLoading {
          LoadingView()
        } else if let error = store.error {
          ErrorView(error: error) {
            store.send(.onAppear)
          }
        } else {
          settingsContent
        }
      }
      .navigationTitle("Settings")
      .onAppear { store.send(.onAppear) }
    }
  }
  
  private var settingsContent: some View {
    Form {
      Section("Appearance") {
        Toggle("Dark Mode", isOn: $store.settings.isDarkModeEnabled)
          .onChange(of: store.settings.isDarkModeEnabled) { _ in
            store.send(.toggleDarkMode)
          }
      }
      
      Section("Notifications") {
        Toggle("Enable Notifications", isOn: $store.settings.notificationsEnabled)
          .onChange(of: store.settings.notificationsEnabled) { _ in
            store.send(.toggleNotifications)
          }
      }
    }
  }
}
```

### 2. Add Common UI Components

Use shared components from `CommonUI`:

```swift
ContentCard {
  VStack(alignment: .leading) {
    Text("Privacy Settings")
      .font(.headline)
    
    Toggle("Analytics", isOn: $store.settings.analyticsEnabled)
  }
}
```

### 3. Create Previews

Add SwiftUI previews for development:

```swift
#Preview("Settings") {
  SettingsView(
    store: Store(initialState: Settings.State()) {
      Settings()
    }
  )
}

#Preview("Settings - Loading") {
  SettingsView(
    store: Store(initialState: Settings.State(isLoading: true)) {
      Settings()
    }
  )
}
```

## Adding to Navigation

### 1. Update Package.swift

Add your new modules to the package:

```swift
.library(name: "SettingsCore", targets: ["SettingsCore"]),
.library(name: "SettingsSwiftUI", targets: ["SettingsSwiftUI"]),

.target(
  name: "SettingsCore",
  dependencies: [
    .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  ]
),
.target(
  name: "SettingsSwiftUI", 
  dependencies: ["SettingsCore", "CommonUI"]
),
```

### 2. Update AppCore

Add your feature to the main app flow:

```swift
// Add to MainTab.State
public struct State: Equatable {
  var selectedTab: Tab = .home
  var home = Home.State()
  var profile = Profile.State()
  var settings = Settings.State()  // Add this
  
  public enum Tab: String, CaseIterable {
    case home = "Home"
    case profile = "Profile"
    case settings = "Settings"  // Add this
  }
}

// Add to actions
public enum Action: BindableAction {
  case binding(BindingAction<State>)
  case home(Home.Action)
  case profile(Profile.Action)
  case settings(Settings.Action)  // Add this
}

// Add to reducer body
Scope(state: \.settings, action: \.settings) {
  Settings()
}
```

### 3. Update AppSwiftUI

Add the tab to your UI:

```swift
NavigationView {
  SettingsView(store: store.scope(state: \.settings, action: \.settings))
}
.tabItem {
  Image(systemName: MainTab.State.Tab.settings.systemImage)
  Text(MainTab.State.Tab.settings.rawValue)
}
.tag(MainTab.State.Tab.settings)
```

## Writing Tests

### 1. Test State Changes

Test that actions properly update state:

```swift
@Test
func toggleDarkMode() async {
  let store = TestStore(initialState: Settings.State()) {
    Settings()
  }
  
  await store.send(.toggleDarkMode) {
    $0.settings.isDarkModeEnabled = true
  }
}
```

### 2. Test Side Effects

Test async operations and effects:

```swift
@Test
func saveSettings() async {
  let store = TestStore(initialState: Settings.State()) {
    Settings()
  } withDependencies: {
    $0.settingsClient.saveSettings = { _ in }
  }
  
  await store.send(.saveSettings) {
    $0.isLoading = true
  }
  
  await store.receive(.settingsSaved) {
    $0.isLoading = false
  }
}
```

### 3. Test Error Handling

Test error scenarios:

```swift
@Test
func saveSettingsFailure() async {
  let store = TestStore(initialState: Settings.State()) {
    Settings()
  } withDependencies: {
    $0.settingsClient.saveSettings = { _ in
      throw SettingsError.saveFailed("Network error")
    }
  }
  
  await store.send(.saveSettings) {
    $0.isLoading = true
  }
  
  await store.receive(.errorOccurred(.saveFailed("Network error"))) {
    $0.isLoading = false
    $0.error = .saveFailed("Network error")
  }
}
```

## Best Practices

### 1. Start Simple

Begin with basic functionality and iterate:

1. Basic state and actions
2. Simple UI
3. Add complexity gradually

### 2. Test Early and Often

Write tests as you develop:

- Test state changes immediately
- Mock dependencies for isolation
- Test both success and failure cases

### 3. Use Type Safety

Leverage Swift's type system:

```swift
// Use enums for finite states
enum LoadingState {
  case idle
  case loading
  case loaded
  case failed(Error)
}

// Use associated values for context
enum Action {
  case itemSelected(id: String)
  case dataLoaded(Result<[Item], Error>)
}
```

### 4. Keep Views Simple

Views should be thin and focused on presentation:

- Move logic to reducers
- Use computed properties for derived state
- Extract complex views into components

### 5. Handle All States

Ensure your UI handles all possible states:

- Loading states
- Error states  
- Empty states
- Success states

### 6. Use Previews Extensively

Create previews for all states:

```swift
#Preview("Loading") { /* loading state */ }
#Preview("Error") { /* error state */ }
#Preview("Empty") { /* empty state */ }
#Preview("Content") { /* normal content */ }
```

## Conclusion

Following this guide will help you create well-structured, testable features that integrate seamlessly with the TCA Template architecture. Remember to:

- Plan before coding
- Start simple and iterate
- Test thoroughly
- Follow established patterns
- Use the provided tools and scripts

For more information, see:
- [Architecture Guide](architecture.md)
- [Testing Guide](testing.md)
- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
