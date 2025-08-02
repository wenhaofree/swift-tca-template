import AuthenticationClient
import ComposableArchitecture
import LoginCore
import SwiftUI
import TwoFactorCore
import TwoFactorSwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct LoginView: View {
  @Perception.Bindable public var store: StoreOf<Login>

  public init(store: StoreOf<Login>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Text(
        """
        To login use any email and "password" for the password. If your email contains the \
        characters "2fa" you will be taken to a two-factor flow, and on that screen you can \
        use "1234" for the code.
        """
      )

      Section {
        TextField("blob@pointfree.co", text: $store.email)
          #if os(iOS)
          .autocapitalization(.none)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          #endif

        SecureField("••••••••", text: $store.password)
      }

      Button {
        // NB: SwiftUI will print errors to the console about "AttributeGraph: cycle detected" if
        //     you disable a text field while it is focused. This hack will force all fields to
        //     unfocus before we send the action to the store.
        // CF: https://stackoverflow.com/a/69653555
        #if canImport(UIKit)
        _ = UIApplication.shared.sendAction(
          #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
        #endif
        store.send(.view(.loginButtonTapped))
      } label: {
        HStack {
          Text("Log in")
          if store.isActivityIndicatorVisible {
            Spacer()
            Text("Loading...")
          }
        }
      }
      .disabled(store.isLoginButtonDisabled)
    }
    .disabled(store.isFormDisabled)
  }
}

extension Login.State {
  fileprivate var isActivityIndicatorVisible: Bool { self.isLoginRequestInFlight }
  fileprivate var isFormDisabled: Bool { self.isLoginRequestInFlight }
  fileprivate var isLoginButtonDisabled: Bool { !self.isFormValid }
}

#Preview {
  NavigationView {
    LoginView(
      store: Store(initialState: Login.State()) {
        Login()
      } withDependencies: {
        $0.authenticationClient.login = { @Sendable _, _ in
          AuthenticationResponse(token: "deadbeef", twoFactorRequired: false)
        }
        $0.authenticationClient.twoFactor = { @Sendable _, _ in
          AuthenticationResponse(token: "deadbeef", twoFactorRequired: false)
        }
      }
    )
  }
}
