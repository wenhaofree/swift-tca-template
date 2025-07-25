import ComposableArchitecture
import CommonUI
import HomeCore
import SwiftUI

public struct HomeView: View {
  let store: StoreOf<Home>
  
  public init(store: StoreOf<Home>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      Group {
        if store.isLoading && store.items.isEmpty {
          LoadingView(message: "Loading content...")
        } else if let error = store.error {
          ErrorView(error: error) {
            store.send(.refresh)
          }
        } else if store.filteredItems.isEmpty && !store.searchText.isEmpty {
          EmptyStateView(
            title: "No Results",
            message: "No items found for '\(store.searchText)'",
            systemImage: "magnifyingglass"
          )
        } else if store.items.isEmpty {
          EmptyStateView(
            title: "Welcome!",
            message: "Your content will appear here",
            systemImage: "house",
            actionTitle: "Refresh",
            action: { store.send(.refresh) }
          )
        } else {
          contentView
        }
      }
      .navigationTitle("Home")
      .navigationStyle()
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
  
  private var contentView: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(store.filteredItems) { item in
          HomeItemView(item: item) {
            store.send(.itemTapped(item))
          }
        }
      }
      .padding()
    }
  }
}

struct HomeItemView: View {
  let item: HomeItem
  let action: () -> Void
  
  var body: some View {
    ContentCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
              .font(.headline)
              .foregroundColor(.primary)
            
            if let subtitle = item.subtitle {
              Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          
          Spacer()
          
          CategoryBadge(category: item.category)
        }
        
        HStack {
          Text(item.createdAt, style: .relative)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Button("View") {
            action()
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.small)
        }
      }
    }
    .onTapGesture {
      action()
    }
  }
}

struct CategoryBadge: View {
  let category: HomeItem.Category
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: category.systemImage)
        .font(.caption)
      
      Text(category.rawValue)
        .font(.caption)
        .fontWeight(.medium)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(categoryColor.opacity(0.2))
    )
    .foregroundColor(categoryColor)
  }
  
  private var categoryColor: Color {
    switch category {
    case .featured:
      return .orange
    case .recent:
      return .blue
    case .popular:
      return .red
    case .recommended:
      return .green
    }
  }
}

// MARK: - Previews

#Preview("Home View - Loading") {
  NavigationView {
    HomeView(
      store: StoreOf<Home>(initialState: Home.State()) {
        Home()
      }
    )
  }
}

#Preview("Home View - Content") {
  NavigationView {
    HomeView(
      store: StoreOf<Home>(initialState: Home.State()) {
        Home()
      }
    )
  }
}

#Preview("Home View - Empty") {
  NavigationView {
    HomeView(
      store: StoreOf<Home>(initialState: Home.State()) {
        Home()
      }
    )
  }
}

#Preview("Home View - Error") {
  NavigationView {
    HomeView(
      store: StoreOf<Home>(initialState: Home.State()) {
        Home()
      }
    )
  }
}

#Preview("Category Badge") {
  VStack(spacing: 8) {
    CategoryBadge(category: .featured)
    CategoryBadge(category: .recent)
    CategoryBadge(category: .popular)
    CategoryBadge(category: .recommended)
  }
  .padding()
}
