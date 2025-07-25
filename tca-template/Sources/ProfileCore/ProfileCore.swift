import ComposableArchitecture
import AuthenticationClient
import Foundation

@Reducer
public struct Profile: Sendable {
  @ObservableState
  public struct State: Equatable {
    public var user: User?
    public var isLoading = false
    public var error: ProfileError?
    public var isEditingProfile = false
    public var editableUser: EditableUser?
    
    public init() {}
    
    public var displayName: String {
      user?.displayName ?? "Unknown User"
    }
    
    public var initials: String {
      let components = displayName.components(separatedBy: " ")
      let initials = components.compactMap { $0.first }.prefix(2)
      return String(initials).uppercased()
    }
  }
  
  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    case loadProfile
    case profileLoaded(User)
    case profileLoadFailed(ProfileError)
    case editProfileButtonTapped
    case saveProfileButtonTapped
    case cancelEditingButtonTapped
    case logoutButtonTapped
    case clearError
  }
  
  @Dependency(\.authenticationClient) var authenticationClient
  
  public init() {}
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        guard state.user == nil && !state.isLoading else { return .none }
        return .send(.loadProfile)
        
      case .loadProfile:
        state.isLoading = true
        state.error = nil
        
        return .run { send in
          do {
            let user = try await loadUserProfile()
            await send(.profileLoaded(user))
          } catch {
            await send(.profileLoadFailed(.networkError(error.localizedDescription)))
          }
        }
        
      case let .profileLoaded(user):
        state.isLoading = false
        state.user = user
        return .none
        
      case let .profileLoadFailed(error):
        state.isLoading = false
        state.error = error
        return .none
        
      case .editProfileButtonTapped:
        guard let user = state.user else { return .none }
        state.isEditingProfile = true
        state.editableUser = EditableUser(from: user)
        return .none
        
      case .saveProfileButtonTapped:
        guard let editableUser = state.editableUser else { return .none }
        
        state.isLoading = true
        
        return .run { [editableUser] send in
          do {
            let updatedUser = try await saveUserProfile(editableUser)
            await send(.profileLoaded(updatedUser))
          } catch {
            await send(.profileLoadFailed(.updateFailed(error.localizedDescription)))
          }
        }
        
      case .cancelEditingButtonTapped:
        state.isEditingProfile = false
        state.editableUser = nil
        return .none
        
      case .logoutButtonTapped:
        // This action will be handled by the parent reducer
        return .none
        
      case .clearError:
        state.error = nil
        return .none
      }
    }
  }
}

// MARK: - Models

public struct User: Equatable, Sendable {
  public let id: String
  public let email: String
  public let firstName: String
  public let lastName: String
  public let avatarURL: String?
  public let bio: String?
  public let joinedAt: Date
  public let isVerified: Bool
  
  public init(
    id: String,
    email: String,
    firstName: String,
    lastName: String,
    avatarURL: String? = nil,
    bio: String? = nil,
    joinedAt: Date = Date(),
    isVerified: Bool = false
  ) {
    self.id = id
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.avatarURL = avatarURL
    self.bio = bio
    self.joinedAt = joinedAt
    self.isVerified = isVerified
  }
  
  public var displayName: String {
    "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
  }
  
  public var fullName: String {
    displayName.isEmpty ? email : displayName
  }
}

public struct EditableUser: Equatable, Sendable {
  public var firstName: String
  public var lastName: String
  public var bio: String
  
  public init(firstName: String, lastName: String, bio: String = "") {
    self.firstName = firstName
    self.lastName = lastName
    self.bio = bio
  }
  
  public init(from user: User) {
    self.firstName = user.firstName
    self.lastName = user.lastName
    self.bio = user.bio ?? ""
  }
}

public enum ProfileError: Error, Equatable, LocalizedError, Sendable {
  case networkError(String)
  case updateFailed(String)
  case unauthorized
  case userNotFound
  case validationError(String)
  
  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "Network error: \(message)"
    case .updateFailed(let message):
      return "Failed to update profile: \(message)"
    case .unauthorized:
      return "You are not authorized to perform this action"
    case .userNotFound:
      return "User profile not found"
    case .validationError(let message):
      return "Validation error: \(message)"
    }
  }
}

// MARK: - API Response Models

private struct UserResponse: Codable {
  let id: String
  let email: String
  let firstName: String
  let lastName: String
  let avatarURL: String?
  let bio: String?
  let joinedAt: String
  let isVerified: Bool
}

private struct UpdateUserRequest: Codable {
  let firstName: String
  let lastName: String
  let bio: String
}

// MARK: - Private API Functions

private func loadUserProfile() async throws -> User {
  // This is a mock implementation
  // In a real app, you would make an actual API call
  
  // Simulate network delay
  try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
  
  // Return mock user data
  return User(
    id: "user123",
    email: "user@example.com",
    firstName: "John",
    lastName: "Doe",
    bio: "iOS Developer passionate about SwiftUI and TCA",
    joinedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
    isVerified: true
  )
}

private func saveUserProfile(_ editableUser: EditableUser) async throws -> User {
  // This is a mock implementation
  // In a real app, you would make an actual API call
  
  // Simulate network delay
  try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
  
  // Validate input
  guard !editableUser.firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
    throw ProfileError.validationError("First name cannot be empty")
  }
  
  guard !editableUser.lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
    throw ProfileError.validationError("Last name cannot be empty")
  }
  
  // Return updated user
  return User(
    id: "user123",
    email: "user@example.com",
    firstName: editableUser.firstName,
    lastName: editableUser.lastName,
    bio: editableUser.bio.isEmpty ? nil : editableUser.bio,
    joinedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
    isVerified: true
  )
}

// MARK: - Real API Implementation (commented out)

/*
private func loadUserProfile() async throws -> User {
  let request = try RequestBuilder(baseURL: URL(string: "https://api.example.com")!)
    .path("/user/profile")
    .method(.GET)
    .acceptJSON()
    .bearerToken(getCurrentToken()) // You'd need to implement token management
    .build()
  
  let response: UserResponse = try await networkClient.requestDecodable(request, as: UserResponse.self)
  
  let dateFormatter = ISO8601DateFormatter()
  let joinedAt = dateFormatter.date(from: response.joinedAt) ?? Date()
  
  return User(
    id: response.id,
    email: response.email,
    firstName: response.firstName,
    lastName: response.lastName,
    avatarURL: response.avatarURL,
    bio: response.bio,
    joinedAt: joinedAt,
    isVerified: response.isVerified
  )
}

private func saveUserProfile(_ editableUser: EditableUser) async throws -> User {
  let requestBody = UpdateUserRequest(
    firstName: editableUser.firstName,
    lastName: editableUser.lastName,
    bio: editableUser.bio
  )
  
  let request = try RequestBuilder(baseURL: URL(string: "https://api.example.com")!)
    .path("/user/profile")
    .method(.PUT)
    .body(requestBody)
    .bearerToken(getCurrentToken())
    .build()
  
  let response: UserResponse = try await networkClient.requestDecodable(request, as: UserResponse.self)
  
  let dateFormatter = ISO8601DateFormatter()
  let joinedAt = dateFormatter.date(from: response.joinedAt) ?? Date()
  
  return User(
    id: response.id,
    email: response.email,
    firstName: response.firstName,
    lastName: response.lastName,
    avatarURL: response.avatarURL,
    bio: response.bio,
    joinedAt: joinedAt,
    isVerified: response.isVerified
  )
}
*/
