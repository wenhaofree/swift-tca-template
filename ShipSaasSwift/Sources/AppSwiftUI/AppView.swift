import AppCore
import ComposableArchitecture
import LoginSwiftUI
import HomeSwiftUI
import ProfileSwiftUI
import SwiftUI

public struct AppView: View {
  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    switch store.case {
    case let .login(store):
      NavigationView {
        LoginView(store: store)
      }
    case let .main(store):
      MainTabView(store: store)
    }
  }
}

public struct MainTabView: View {
  let store: StoreOf<MainTab>

  public init(store: StoreOf<MainTab>) {
    self.store = store
  }

  public var body: some View {
    TabView {
      NavigationView {
        HomeView(store: store.scope(state: \.home, action: \.home))
      }
      .tabItem {
        Image(systemName: MainTab.State.Tab.home.systemImage)
        Text(MainTab.State.Tab.home.rawValue)
      }
      .tag(MainTab.State.Tab.home)

      NavigationView {
        ProfileView(store: store.scope(state: \.profile, action: \.profile))
      }
      .tabItem {
        Image(systemName: MainTab.State.Tab.profile.systemImage)
        Text(MainTab.State.Tab.profile.rawValue)
      }
      .tag(MainTab.State.Tab.profile)
    }
  }
}
