import AppCore
import AppSwiftUI
import AuthenticationClientLive
import CommonUI
import ComposableArchitecture
import SwiftUI

private let readMe = """
  Welcome to the ShipSaasSwift - a comprehensive starter template for building iOS applications \
  using Swift Composable Architecture.

  This template includes:
  • Complete authentication flow with two-factor authentication
  • Modular architecture with clear separation of concerns
  • Network layer with proper error handling
  • Common UI components for consistent design
  • Comprehensive testing infrastructure
  • Example features (Home and Profile) to get you started

  The template is designed to be production-ready and follows TCA best practices. You can use it \
  as a starting point for your next iOS project or as a reference for implementing TCA patterns.

  To get started, tap "Launch App" below to see the authentication flow and main application.
  """

struct RootView: View {
  let store = Store(initialState: AppFeature.State.login(.init())) {
    AppFeature.body._printChanges()
  } withDependencies: {
    // Configure live dependencies
    $0.authenticationClient = .liveValue
    // NetworkClient will use its default liveValue
  }

  @State var showApp = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          VStack(alignment: .leading, spacing: 8) {
            Text("ShipSaasSwift")
              .font(.largeTitle)
              .fontWeight(.bold)

            Text("Swift Composable Architecture Starter")
              .font(.title3)
              .foregroundColor(.secondary)
          }

          // Description
          Text(readMe)
            .font(.body)
            .lineSpacing(4)

          // Features
          VStack(alignment: .leading, spacing: 16) {
            Text("Features")
              .font(.title2)
              .fontWeight(.semibold)

            FeatureRow(
              icon: "person.badge.key",
              title: "Authentication",
              description: "Complete login flow with 2FA support"
            )

            FeatureRow(
              icon: "building.2",
              title: "Modular Architecture",
              description: "Clean separation of business logic and UI"
            )

            FeatureRow(
              icon: "network",
              title: "Network Layer",
              description: "Robust networking with error handling"
            )

            FeatureRow(
              icon: "paintbrush",
              title: "Common UI",
              description: "Reusable components for consistent design"
            )

            FeatureRow(
              icon: "checkmark.shield",
              title: "Testing",
              description: "Comprehensive test coverage"
            )
          }

          // Action Button
          Button("Launch App") {
            showApp = true
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .frame(maxWidth: .infinity)
          .padding(.top)
        }
        .padding()
      }
      .sheet(isPresented: $showApp) {
        AppView(store: store)
      }
      .navigationTitle("ShipSaasSwift")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct FeatureRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(.blue)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.headline)

        Text(description)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }
}

#Preview {
  RootView()
}
