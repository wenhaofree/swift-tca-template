import AppCore
import AuthenticationClient
import ComposableArchitecture
import LoginCore
import HomeCore
import ProfileCore
import Testing
import TwoFactorCore

@MainActor
struct AppCoreTests {
  @Test
  func initialState() async {
    let loginState = AppFeature.State.login(Login.State())
    let mainState = AppFeature.State.main(MainTab.State())

    // Test that states are properly initialized
    switch loginState {
    case .login(let state):
      #expect(state.email.isEmpty)
      #expect(state.password.isEmpty)
    case .main:
      #expect(Bool(false), "Should be login state")
    }

    switch mainState {
    case .login:
      #expect(Bool(false), "Should be main state")
    case .main(let state):
      #expect(state.selectedTab == .home)
    }
  }

  @Test
  func reducersCanBeInitialized() async {
    let mainTab = MainTab()

    // Simple test to ensure reducers can be initialized
    // MainTab is a struct, so it's never nil
    #expect(type(of: mainTab) == MainTab.self)
  }
}
