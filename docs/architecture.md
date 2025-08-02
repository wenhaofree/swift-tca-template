# ShipSaasSwift Architecture Guide

This document provides a comprehensive overview of the ShipSaasSwift architecture, design patterns, and best practices.

## 📋 Table of Contents

- [Overview](#overview)
- [Core Principles](#core-principles)
- [Module Structure](#module-structure)
- [Data Flow](#data-flow)
- [Dependency Management](#dependency-management)
- [Testing Strategy](#testing-strategy)
- [Best Practices](#best-practices)

## Overview

The ShipSaasSwift follows the **Swift Composable Architecture (TCA)** pattern, which provides a consistent and predictable way to build applications. The architecture emphasizes:

- **Unidirectional data flow**
- **Immutable state management**
- **Composable and testable components**
- **Clear separation of concerns**

## Core Principles

### 1. State-Driven UI

All UI components are driven by state. The UI is a pure function of the current state:

```swift
UI = f(State)
```

### 2. Actions as Events

User interactions and system events are represented as actions:

```swift
enum Action {
  case buttonTapped
  case dataLoaded([Item])
  case errorOccurred(Error)
}
```

### 3. Reducers Handle Logic

Reducers are pure functions that handle state mutations:

```swift
func reduce(state: inout State, action: Action) -> Effect<Action> {
  switch action {
  case .buttonTapped:
    state.isLoading = true
    return .run { send in
      let data = try await loadData()
      await send(.dataLoaded(data))
    }
  }
}
```

### 4. Effects for Side Effects

All side effects (network calls, database operations, etc.) are handled through Effects:

```swift
return .run { send in
  let result = try await networkClient.request(...)
  await send(.dataLoaded(result))
}
```

## Module Structure

The template uses a modular architecture with clear boundaries:

### Core Modules

**Purpose**: Business logic, state management, and data flow
**Naming**: `*Core` (e.g., `LoginCore`, `HomeCore`)
**Dependencies**: TCA, domain-specific clients

```
FeatureCore/
├── FeatureCore.swift      # Main reducer and state
├── Models.swift           # Domain models
└── API.swift             # API integration (optional)
```

### UI Modules

**Purpose**: SwiftUI views and UI components
**Naming**: `*SwiftUI` (e.g., `LoginSwiftUI`, `HomeSwiftUI`)
**Dependencies**: Corresponding Core module, CommonUI

```
FeatureSwiftUI/
├── FeatureView.swift      # Main view
├── Components/            # Feature-specific components
└── Previews.swift        # SwiftUI previews
```

### Client Modules

**Purpose**: External service interfaces and implementations
**Naming**: `*Client` and `*ClientLive`
**Dependencies**: Dependencies framework

```
ServiceClient/
├── ServiceClient.swift    # Protocol definition
└── Models.swift          # Service-specific models

ServiceClientLive/
└── LiveServiceClient.swift # Implementation
```

### Shared Modules

**Purpose**: Common utilities and components
**Examples**: `CommonUI`, `NetworkClient`

## Data Flow

The data flow in TCA follows a unidirectional pattern:

```
┌─────────────┐    Action    ┌─────────────┐
│    View     │─────────────▶│   Store     │
│             │              │             │
└─────────────┘              └─────────────┘
       ▲                            │
       │                            │
       │ State                      │ Action
       │                            ▼
┌─────────────┐              ┌─────────────┐
│   Render    │◀─────────────│   Reducer   │
│             │    State     │             │
└─────────────┘              └─────────────┘
                                     │
                                     │ Effect
                                     ▼
                              ┌─────────────┐
                              │ Side Effect │
                              │ (Network,   │
                              │  Database)  │
                              └─────────────┘
```

### Flow Steps

1. **User Interaction**: User taps a button, triggering an action
2. **Action Dispatch**: Action is sent to the store
3. **State Mutation**: Reducer processes the action and updates state
4. **Effect Execution**: Side effects are executed if needed
5. **UI Update**: View re-renders based on new state

## Dependency Management

### Dependency Injection

The template uses TCA's dependency system for clean dependency injection:

```swift
@Dependency(\.networkClient) var networkClient
@Dependency(\.authenticationClient) var authenticationClient
```

### Client Pattern

External dependencies are abstracted through client protocols:

```swift
@DependencyClient
struct NetworkClient {
  var request: (NetworkRequest) async throws -> Data
}

extension NetworkClient: DependencyKey {
  static let liveValue = NetworkClient(
    request: { request in
      // Live implementation
    }
  )
}
```

### Testing Dependencies

Test dependencies provide controlled behavior for testing:

```swift
extension NetworkClient: TestDependencyKey {
  static let testValue = NetworkClient(
    request: { _ in Data() }
  )
}
```

## Testing Strategy

### Unit Tests

Test individual reducers and business logic:

```swift
@Test
func loginSuccess() async {
  let store = TestStore(initialState: Login.State()) {
    Login()
  } withDependencies: {
    $0.authenticationClient.login = { _, _ in
      AuthenticationResponse(token: "test", twoFactorRequired: false)
    }
  }
  
  await store.send(.loginButtonTapped) {
    $0.isLoading = true
  }
  
  await store.receive(.loginResponse(.success(...))) {
    $0.isLoading = false
    // Assert state changes
  }
}
```

### Integration Tests

Test feature interactions and data flow:

```swift
@Test
func loginToHomeFlow() async {
  let store = TestStore(initialState: AppFeature.State.login(.init())) {
    AppFeature()
  }
  
  // Test complete flow from login to home
}
```

### UI Tests

Test user interface and user flows:

```swift
@Test
func loginFlow() async {
  let app = XCUIApplication()
  app.launch()
  
  app.textFields["email"].tap()
  app.textFields["email"].typeText("test@example.com")
  // ... continue UI test
}
```

## Best Practices

### State Design

1. **Keep state flat**: Avoid deeply nested state structures
2. **Use computed properties**: Derive values from base state
3. **Normalize data**: Store collections as dictionaries with IDs

```swift
@ObservableState
struct State: Equatable {
  var items: [String: Item] = [:]  // Normalized
  var selectedItemID: String?
  
  var selectedItem: Item? {        // Computed
    selectedItemID.flatMap { items[$0] }
  }
}
```

### Action Design

1. **Be specific**: Create specific actions for different events
2. **Include context**: Add necessary data to actions
3. **Avoid generic actions**: Don't use overly broad actions

```swift
enum Action {
  case itemTapped(id: String)           // ✅ Specific
  case loadItems                        // ✅ Clear intent
  case itemsLoaded([Item])             // ✅ Includes data
  
  case genericAction(Any)              // ❌ Too generic
}
```

### Reducer Design

1. **Keep reducers pure**: No side effects in reducer logic
2. **Handle all cases**: Ensure all actions are handled
3. **Use composition**: Break large reducers into smaller ones

```swift
var body: some Reducer<State, Action> {
  Reduce { state, action in
    // Handle actions
  }
  .ifLet(\.childState, action: \.childAction) {
    ChildReducer()
  }
}
```

### Effect Design

1. **Handle errors**: Always handle potential failures
2. **Use structured concurrency**: Leverage async/await
3. **Cancel when needed**: Cancel effects when appropriate

```swift
return .run { send in
  do {
    let data = try await networkClient.request(...)
    await send(.dataLoaded(data))
  } catch {
    await send(.errorOccurred(error))
  }
}
```

### Module Organization

1. **Single responsibility**: Each module has one clear purpose
2. **Minimal dependencies**: Reduce coupling between modules
3. **Clear interfaces**: Define clear public APIs

### Performance Considerations

1. **Lazy loading**: Load data only when needed
2. **Efficient updates**: Use `@ObservableState` for optimal SwiftUI updates
3. **Memory management**: Be mindful of retain cycles in effects

## Conclusion

The ShipSaasSwift architecture provides a solid foundation for building scalable, testable, and maintainable iOS applications. By following these patterns and best practices, you can create applications that are easy to understand, modify, and extend.

For more detailed information, refer to:
- [TCA Official Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Feature Development Guide](feature-development.md)
- [Testing Guide](testing.md)
