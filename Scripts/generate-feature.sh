#!/bin/bash

# TCA Template - Feature Generator Script
# This script generates a new feature module with Core, SwiftUI, and Tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <FeatureName>"
    echo ""
    echo "Example: $0 Settings"
    echo "This will create:"
    echo "  - SettingsCore module"
    echo "  - SettingsSwiftUI module"
    echo "  - SettingsCoreTests module"
    echo ""
    echo "The feature name should be in PascalCase (e.g., Settings, UserProfile, etc.)"
}

# Check if feature name is provided
if [ $# -eq 0 ]; then
    print_color $RED "Error: Feature name is required"
    show_usage
    exit 1
fi

FEATURE_NAME=$1

# Validate feature name (should be PascalCase)
if [[ ! $FEATURE_NAME =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    print_color $RED "Error: Feature name should be in PascalCase (e.g., Settings, UserProfile)"
    exit 1
fi

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCES_DIR="$PROJECT_ROOT/tca-template/Sources"
TESTS_DIR="$PROJECT_ROOT/tca-template/Tests"

CORE_MODULE="${FEATURE_NAME}Core"
UI_MODULE="${FEATURE_NAME}SwiftUI"
TEST_MODULE="${FEATURE_NAME}CoreTests"

print_color $BLUE "Generating feature: $FEATURE_NAME"
print_color $YELLOW "Project root: $PROJECT_ROOT"

# Create directories
print_color $YELLOW "Creating directories..."
mkdir -p "$SOURCES_DIR/$CORE_MODULE"
mkdir -p "$SOURCES_DIR/$UI_MODULE"
mkdir -p "$TESTS_DIR/$TEST_MODULE"

# Generate Core module
print_color $YELLOW "Generating ${CORE_MODULE}..."
cat > "$SOURCES_DIR/$CORE_MODULE/${CORE_MODULE}.swift" << EOF
import ComposableArchitecture
import Foundation

@Reducer
public struct ${FEATURE_NAME}: Sendable {
  @ObservableState
  public struct State: Equatable {
    public var isLoading = false
    public var error: ${FEATURE_NAME}Error?
    
    public init() {}
  }
  
  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    case refresh
    case clearError
  }
  
  public init() {}
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        // TODO: Implement onAppear logic
        return .none
        
      case .refresh:
        state.error = nil
        // TODO: Implement refresh logic
        return .none
        
      case .clearError:
        state.error = nil
        return .none
      }
    }
  }
}

// MARK: - Models

public enum ${FEATURE_NAME}Error: Error, Equatable, LocalizedError, Sendable {
  case networkError(String)
  case unknown(String)
  
  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "Network error: \(message)"
    case .unknown(let message):
      return "Unknown error: \(message)"
    }
  }
}
EOF

# Generate SwiftUI module
print_color $YELLOW "Generating ${UI_MODULE}..."
cat > "$SOURCES_DIR/$UI_MODULE/${FEATURE_NAME}View.swift" << EOF
import ComposableArchitecture
import CommonUI
import ${CORE_MODULE}
import SwiftUI

public struct ${FEATURE_NAME}View: View {
  let store: StoreOf<${FEATURE_NAME}>
  
  public init(store: StoreOf<${FEATURE_NAME}>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      Group {
        if store.isLoading {
          LoadingView(message: "Loading...")
        } else if let error = store.error {
          ErrorView(error: error) {
            store.send(.refresh)
          }
        } else {
          contentView
        }
      }
      .navigationTitle("${FEATURE_NAME}")
      .navigationStyle()
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
  
  private var contentView: some View {
    ScrollView {
      VStack(spacing: 16) {
        ContentCard {
          VStack {
            Text("${FEATURE_NAME} Feature")
              .font(.headline)
            
            Text("This is a generated feature template. Customize it according to your needs.")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .padding()
        }
        
        PrimaryButton(
          title: "Refresh",
          action: { store.send(.refresh) }
        )
      }
      .padding()
    }
  }
}

// MARK: - Previews

#Preview("${FEATURE_NAME} View") {
  NavigationView {
    ${FEATURE_NAME}View(
      store: Store(initialState: ${FEATURE_NAME}.State()) {
        ${FEATURE_NAME}()
      }
    )
  }
}

#Preview("${FEATURE_NAME} View - Loading") {
  NavigationView {
    ${FEATURE_NAME}View(
      store: Store(initialState: ${FEATURE_NAME}.State(isLoading: true)) {
        ${FEATURE_NAME}()
      }
    )
  }
}

#Preview("${FEATURE_NAME} View - Error") {
  NavigationView {
    ${FEATURE_NAME}View(
      store: Store(
        initialState: ${FEATURE_NAME}.State(
          error: .networkError("Failed to load data")
        )
      ) {
        ${FEATURE_NAME}()
      }
    )
  }
}
EOF

# Generate Tests module
print_color $YELLOW "Generating ${TEST_MODULE}..."
cat > "$TESTS_DIR/$TEST_MODULE/${TEST_MODULE}.swift" << EOF
import ComposableArchitecture
import ${CORE_MODULE}
import Testing

@MainActor
struct ${TEST_MODULE} {
  
  @Test
  func onAppear() async {
    let store = TestStore(initialState: ${FEATURE_NAME}.State()) {
      ${FEATURE_NAME}()
    }
    
    await store.send(.onAppear)
    // TODO: Add expectations for onAppear behavior
  }
  
  @Test
  func refresh_clearsError() async {
    let store = TestStore(
      initialState: ${FEATURE_NAME}.State(
        error: .networkError("Test error")
      )
    ) {
      ${FEATURE_NAME}()
    }
    
    await store.send(.refresh) {
      \$0.error = nil
    }
  }
  
  @Test
  func clearError_removesError() async {
    let store = TestStore(
      initialState: ${FEATURE_NAME}.State(
        error: .unknown("Test error")
      )
    ) {
      ${FEATURE_NAME}()
    }
    
    await store.send(.clearError) {
      \$0.error = nil
    }
  }
  
  @Test
  func ${FEATURE_NAME,,}Error_localizedDescription() {
    let networkError = ${FEATURE_NAME}Error.networkError("Connection failed")
    let unknownError = ${FEATURE_NAME}Error.unknown("Something went wrong")
    
    #expect(networkError.localizedDescription == "Network error: Connection failed")
    #expect(unknownError.localizedDescription == "Unknown error: Something went wrong")
  }
}
EOF

print_color $GREEN "✅ Feature '$FEATURE_NAME' generated successfully!"
print_color $BLUE "Created modules:"
print_color $NC "  - $CORE_MODULE (Sources/$CORE_MODULE/)"
print_color $NC "  - $UI_MODULE (Sources/$UI_MODULE/)"
print_color $NC "  - $TEST_MODULE (Tests/$TEST_MODULE/)"
print_color $YELLOW ""
print_color $YELLOW "Next steps:"
print_color $NC "1. Add the new modules to Package.swift"
print_color $NC "2. Update AppCore.swift to include your new feature"
print_color $NC "3. Customize the generated code according to your needs"
print_color $NC "4. Run tests to ensure everything works correctly"
