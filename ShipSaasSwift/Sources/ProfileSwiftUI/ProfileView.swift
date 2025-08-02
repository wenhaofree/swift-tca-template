import ComposableArchitecture
import CommonUI
import ProfileCore
import SwiftUI

public struct ProfileView: View {
  let store: StoreOf<Profile>
  
  public init(store: StoreOf<Profile>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      Group {
        if store.isLoading && store.user == nil {
          LoadingView(message: "Loading profile...")
        } else if let error = store.error {
          ErrorView(error: error) {
            store.send(.loadProfile)
          }
        } else if let user = store.user {
          if store.isEditingProfile {
            EditProfileView(store: store, user: user)
          } else {
            ProfileContentView(store: store, user: user)
          }
        } else {
          EmptyStateView(
            title: "Profile Not Found",
            message: "Unable to load your profile",
            systemImage: "person.slash",
            actionTitle: "Retry",
            action: { store.send(.loadProfile) }
          )
        }
      }
      .navigationTitle("Profile")
      .navigationStyle()
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
}

struct ProfileContentView: View {
  let store: StoreOf<Profile>
  let user: User
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Profile Header
        ProfileHeaderView(user: user)
        
        // Profile Details
        ProfileDetailsView(user: user)
        
        // Action Buttons
        VStack(spacing: 12) {
          PrimaryButton(
            title: "Edit Profile",
            action: { store.send(.editProfileButtonTapped) }
          )
          
          Button("Sign Out") {
            store.send(.logoutButtonTapped)
          }
          .foregroundColor(.red)
          .frame(maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.red, lineWidth: 1)
          )
        }
        .padding(.horizontal)
      }
      .padding()
    }
    .formStyle()
  }
}

struct EditProfileView: View {
  let store: StoreOf<Profile>
  let user: User
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Profile Header (non-editable)
        ProfileHeaderView(user: user)
        
        // Editable Fields
        if let editableUser = store.editableUser {
          VStack(spacing: 16) {
            StyledTextField(
              title: "First Name",
              text: .constant(editableUser.firstName),
              placeholder: "Enter your first name"
            )

            StyledTextField(
              title: "Last Name",
              text: .constant(editableUser.lastName),
              placeholder: "Enter your last name"
            )

            VStack(alignment: .leading, spacing: 8) {
              Text("Bio")
                .font(.headline)
                .foregroundColor(.primary)

              TextEditor(text: .constant(editableUser.bio))
                .frame(minHeight: 100)
                .padding(8)
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
          }
          .padding(.horizontal)
        }
        
        // Action Buttons
        HStack(spacing: 12) {
          Button("Cancel") {
            store.send(.cancelEditingButtonTapped)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.gray, lineWidth: 1)
          )
          
          PrimaryButton(
            title: "Save",
            isLoading: store.isLoading,
            action: { store.send(.saveProfileButtonTapped) }
          )
        }
        .padding(.horizontal)
      }
      .padding()
    }
    .formStyle()
    #if os(iOS)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Cancel") {
          store.send(.cancelEditingButtonTapped)
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Save") {
          store.send(.saveProfileButtonTapped)
        }
        .disabled(store.isLoading)
      }
    }
    #else
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          store.send(.cancelEditingButtonTapped)
        }
      }

      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          store.send(.saveProfileButtonTapped)
        }
        .disabled(store.isLoading)
      }
    }
    #endif
  }
}

struct ProfileHeaderView: View {
  let user: User
  
  var body: some View {
    ContentCard {
      VStack(spacing: 16) {
        // Avatar
        ZStack {
          Circle()
            .fill(Color.blue)
            .frame(width: 80, height: 80)
          
          if let avatarURL = user.avatarURL {
            AsyncImage(url: URL(string: avatarURL)) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            } placeholder: {
              ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
          } else {
            Text(user.displayName.prefix(2).uppercased())
              .font(.title)
              .fontWeight(.semibold)
              .foregroundColor(.white)
          }
        }
        
        // User Info
        VStack(spacing: 4) {
          HStack {
            Text(user.displayName)
              .font(.title2)
              .fontWeight(.semibold)
            
            if user.isVerified {
              Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.blue)
                .font(.caption)
            }
          }
          
          Text(user.email)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
    }
  }
}

struct ProfileDetailsView: View {
  let user: User
  
  var body: some View {
    ContentCard {
      VStack(alignment: .leading, spacing: 16) {
        Text("About")
          .font(.headline)
        
        if let bio = user.bio, !bio.isEmpty {
          Text(bio)
            .font(.body)
            .foregroundColor(.secondary)
        } else {
          Text("No bio available")
            .font(.body)
            .foregroundColor(.secondary)
            .italic()
        }
        
        Divider()
        
        VStack(alignment: .leading, spacing: 8) {
          Label("Member since", systemImage: "calendar")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Text(user.joinedAt, style: .date)
            .font(.body)
        }
      }
    }
  }
}

// MARK: - Previews

#Preview("Profile View - Content") {
  NavigationView {
    ProfileView(
      store: StoreOf<Profile>(initialState: Profile.State()) {
        Profile()
      }
    )
  }
}

#Preview("Profile View - Loading") {
  NavigationView {
    ProfileView(
      store: StoreOf<Profile>(initialState: Profile.State()) {
        Profile()
      }
    )
  }
}

#Preview("Profile View - Editing") {
  NavigationView {
    ProfileView(
      store: StoreOf<Profile>(initialState: Profile.State()) {
        Profile()
      }
    )
  }
}
