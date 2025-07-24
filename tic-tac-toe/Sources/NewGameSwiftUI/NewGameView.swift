import ComposableArchitecture
import GameCore
import GameSwiftUI
import NewGameCore
import SwiftUI

public struct NewGameView: View {
  @Perception.Bindable var store: StoreOf<NewGame>

  public init(store: StoreOf<NewGame>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section {
        TextField("Blob Sr.", text: $store.xPlayerName)
          #if os(iOS)
          .autocapitalization(.words)
          .disableAutocorrection(true)
          .textContentType(.name)
          #endif
      } header: {
        Text("X Player Name")
      }

      Section {
        TextField("Blob Jr.", text: $store.oPlayerName)
          #if os(iOS)
          .autocapitalization(.words)
          .disableAutocorrection(true)
          .textContentType(.name)
          #endif
      } header: {
        Text("O Player Name")
      }

      Button("Let's play!") {
        store.send(.letsPlayButtonTapped)
      }
      .disabled(store.isLetsPlayButtonDisabled)
    }
    #if os(iOS)
    .navigationBarItems(trailing: Button("Logout") { store.send(.logoutButtonTapped) })
    #endif
  }
}

extension NewGame.State {
  fileprivate var isLetsPlayButtonDisabled: Bool {
    self.oPlayerName.isEmpty || self.xPlayerName.isEmpty
  }
}

#Preview {
  NavigationView {
    NewGameView(
      store: Store(initialState: NewGame.State()) {
        NewGame()
      }
    )
  }
}
