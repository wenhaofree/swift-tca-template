import AppCore
import AppSwiftUI
import AuthenticationClientLive
import ComposableArchitecture
import SwiftUI

private let readMe = """
  This application demonstrates how to build a moderately complex application in the Composable \
  Architecture.

  It includes a login with two-factor authentication, navigation flows, side effects, game logic, \
  and a full test suite.

  This application is super-modularized to demonstrate that it's possible. The core business logic \
  for each screen is put into its own module, and each view is put into its own module.

  Further, the app has been built in both SwiftUI and UIKit to demonstrate how the patterns \
  translate for each platform. The core business logic is only written a single time, and both \
  SwiftUI and UIKit are run from those modules by adapting their domain to the domain that makes \
  most sense for each platform.
  """

struct RootView: View {
  let store = Store(initialState: TicTacToe.State.login(.init())) {
    TicTacToe.body._printChanges()
  }

  @State var showGame = false

  var body: some View {
    NavigationView {
      Form {
        Text(readMe)

        Section {
          Button("Start Game") { showGame = true }
        }
      }
      .sheet(isPresented: $showGame) {
        AppView(store: store)
      }
      .navigationTitle("Tic-Tac-Toe")
    }
  }
}

#Preview {
  RootView()
}
