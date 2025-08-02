import ComposableArchitecture
import LoginCore
import HomeCore
import ProfileCore

@Reducer
public enum AppFeature {
  case login(Login)
  case main(MainTab)

  public static var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .login(.twoFactor(.presented(.twoFactorResponse(.success)))):
        state = .main(MainTab.State())
        return .none

      case let .login(.loginResponse(.success(response))) where !response.twoFactorRequired:
        state = .main(MainTab.State())
        return .none

      case .login:
        return .none

      case .main(.logoutButtonTapped):
        state = .login(Login.State())
        return .none

      case .main:
        return .none
      }
    }
    .ifCaseLet(\.login, action: \.login) {
      Login()
    }
    .ifCaseLet(\.main, action: \.main) {
      MainTab()
    }
  }
}

@Reducer
public struct MainTab {
  @ObservableState
  public struct State: Equatable {
    public var selectedTab: Tab = .home
    public var home = Home.State()
    public var profile = Profile.State()

    public init() {}

    public enum Tab: String, CaseIterable {
      case home = "Home"
      case profile = "Profile"

      public var systemImage: String {
        switch self {
        case .home: return "house"
        case .profile: return "person"
        }
      }
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case home(Home.Action)
    case profile(Profile.Action)
    case logoutButtonTapped
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Scope(state: \.home, action: \.home) {
      Home()
    }

    Scope(state: \.profile, action: \.profile) {
      Profile()
    }

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .home:
        return .none

      case .profile(.logoutButtonTapped):
        return .send(.logoutButtonTapped)

      case .profile:
        return .none

      case .logoutButtonTapped:
        return .none
      }
    }
  }
}

extension AppFeature.State: Equatable {}
