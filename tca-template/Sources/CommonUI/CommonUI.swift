import ComposableArchitecture
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Common UI Components

/// A reusable button component with consistent styling
public struct PrimaryButton: View {
  let title: String
  let action: () -> Void
  let isLoading: Bool
  let isDisabled: Bool
  
  public init(
    title: String,
    isLoading: Bool = false,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isLoading = isLoading
    self.isDisabled = isDisabled
    self.action = action
  }
  
  public var body: some View {
    Button(action: action) {
      HStack {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.8)
        }
        Text(title)
          .font(.headline)
          .foregroundColor(.white)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(isDisabled ? Color.gray : Color.blue)
      )
    }
    .disabled(isDisabled || isLoading)
  }
}

/// A reusable text field component with consistent styling
public struct StyledTextField: View {
  let title: String
  @Binding var text: String
  let placeholder: String
  let isSecure: Bool
  
  public init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    isSecure: Bool = false
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.isSecure = isSecure
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)
        .foregroundColor(.primary)
      
      Group {
        if isSecure {
          SecureField(placeholder, text: $text)
        } else {
          TextField(placeholder, text: $text)
        }
      }
      .textFieldStyle(RoundedBorderTextFieldStyle())
      #if os(iOS)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled(true)
      #endif
    }
  }
}

/// A reusable card component for content sections
public struct ContentCard<Content: View>: View {
  let content: Content
  
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  public var body: some View {
    VStack {
      content
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(systemBackgroundColor)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    )
  }
}

/// A reusable loading view
public struct LoadingView: View {
  let message: String
  
  public init(message: String = "Loading...") {
    self.message = message
  }
  
  public var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
        .scaleEffect(1.5)

      Text(message)
        .font(.body)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(systemBackgroundColor)
  }
}

/// A reusable error view
public struct ErrorView: View {
  let error: Error
  let retryAction: (() -> Void)?
  
  public init(error: Error, retryAction: (() -> Void)? = nil) {
    self.error = error
    self.retryAction = retryAction
  }
  
  public var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 48))
        .foregroundColor(.red)
      
      Text("Something went wrong")
        .font(.headline)
      
      Text(error.localizedDescription)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      if let retryAction = retryAction {
        Button("Try Again", action: retryAction)
          .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(systemBackgroundColor)
  }
}

/// A reusable empty state view
public struct EmptyStateView: View {
  let title: String
  let message: String
  let systemImage: String
  let actionTitle: String?
  let action: (() -> Void)?
  
  public init(
    title: String,
    message: String,
    systemImage: String = "tray",
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.systemImage = systemImage
    self.actionTitle = actionTitle
    self.action = action
  }
  
  public var body: some View {
    VStack(spacing: 16) {
      Image(systemName: systemImage)
        .font(.system(size: 48))
        .foregroundColor(.secondary)
      
      Text(title)
        .font(.headline)
      
      Text(message)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      if let actionTitle = actionTitle, let action = action {
        Button(actionTitle, action: action)
          .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(systemBackgroundColor)
  }
}





// MARK: - View Extensions

public extension View {
  /// Applies a consistent navigation style
  func navigationStyle() -> some View {
    #if os(iOS)
    return self
      .navigationBarTitleDisplayMode(.large)
    #else
    return self
    #endif
  }

  /// Applies a consistent form style
  func formStyle() -> some View {
    self
      .background(systemGroupedBackgroundColor)
  }
}

// MARK: - Color Extensions

public extension Color {
  static let primaryAccent = Color.blue
  static let secondaryAccent = Color.gray
  static let successColor = Color.green
  static let warningColor = Color.orange
  static let errorColor = Color.red
}

// MARK: - System Colors

private var systemBackgroundColor: Color {
  #if canImport(UIKit)
  return Color(UIColor.systemBackground)
  #else
  return Color(.windowBackgroundColor)
  #endif
}

private var systemGroupedBackgroundColor: Color {
  #if canImport(UIKit)
  return Color(UIColor.systemGroupedBackground)
  #else
  return Color(.controlBackgroundColor)
  #endif
}

// MARK: - Font Extensions

public extension Font {
  static let customLargeTitle = Font.largeTitle.weight(.bold)
  static let customTitle = Font.title.weight(.semibold)
  static let customHeadline = Font.headline.weight(.medium)
  static let customBody = Font.body
  static let customCaption = Font.caption
}
