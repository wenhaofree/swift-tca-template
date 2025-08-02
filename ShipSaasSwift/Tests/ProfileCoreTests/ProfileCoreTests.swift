import ComposableArchitecture
import ProfileCore
import Testing

@MainActor
struct ProfileCoreTests {
  
  @Test
  func initialState() async {
    let state = Profile.State()
    #expect(state.user == nil)
    #expect(state.isLoading == false)
    #expect(state.error == nil)
    #expect(state.isEditingProfile == false)
    #expect(state.editableUser == nil)
  }
  
  @Test
  func clearError() async {
    var initialState = Profile.State()
    initialState.error = .networkError("Test error")

    let store = TestStore(initialState: initialState) {
      Profile()
    }

    await store.send(.clearError) {
      $0.error = nil
    }
  }
  
  @Test
  func userDisplayName() {
    let user1 = User(
      id: "1",
      email: "test@example.com",
      firstName: "John",
      lastName: "Doe"
    )
    
    let user2 = User(
      id: "2",
      email: "test@example.com",
      firstName: "",
      lastName: ""
    )
    
    #expect(user1.displayName == "John Doe")
    #expect(user2.displayName == "")
    #expect(user1.fullName == "John Doe")
    #expect(user2.fullName == "test@example.com")
  }
  
  @Test
  func editableUserInitFromUser() {
    let user = User(
      id: "1",
      email: "test@example.com",
      firstName: "John",
      lastName: "Doe",
      bio: "Test bio"
    )
    
    let editableUser = EditableUser(from: user)
    
    #expect(editableUser.firstName == "John")
    #expect(editableUser.lastName == "Doe")
    #expect(editableUser.bio == "Test bio")
  }
  
  @Test
  func editableUserInitFromUserWithNilBio() {
    let user = User(
      id: "1",
      email: "test@example.com",
      firstName: "John",
      lastName: "Doe",
      bio: nil
    )
    
    let editableUser = EditableUser(from: user)
    
    #expect(editableUser.bio == "")
  }
  
  @Test
  func profileErrorLocalizedDescription() {
    let networkError = ProfileError.networkError("Connection failed")
    let updateError = ProfileError.updateFailed("Update failed")
    let unauthorizedError = ProfileError.unauthorized
    let notFoundError = ProfileError.userNotFound
    let validationError = ProfileError.validationError("Invalid input")
    
    #expect(networkError.localizedDescription == "Network error: Connection failed")
    #expect(updateError.localizedDescription == "Failed to update profile: Update failed")
    #expect(unauthorizedError.localizedDescription == "You are not authorized to perform this action")
    #expect(notFoundError.localizedDescription == "User profile not found")
    #expect(validationError.localizedDescription == "Validation error: Invalid input")
  }
  
  @Test
  func profileStateDisplayName() {
    let user = User(
      id: "1",
      email: "test@example.com",
      firstName: "John",
      lastName: "Doe"
    )
    
    var state1 = Profile.State()
    state1.user = user
    let state2 = Profile.State()
    
    #expect(state1.displayName == "John Doe")
    #expect(state2.displayName == "Unknown User")
  }
  
  @Test
  func profileStateInitials() {
    let user = User(
      id: "1",
      email: "test@example.com",
      firstName: "John",
      lastName: "Doe"
    )
    
    var state = Profile.State()
    state.user = user
    
    #expect(state.initials == "JD")
  }
  
  @Test
  func logoutButtonTapped() async {
    let store = TestStore(initialState: Profile.State()) {
      Profile()
    }
    
    await store.send(.logoutButtonTapped)
    // This action should be handled by parent reducer
  }
}
