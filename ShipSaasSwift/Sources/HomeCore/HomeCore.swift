import ComposableArchitecture
import NetworkClient
import Foundation

@Reducer
public struct Home: Sendable {
  @ObservableState
  public struct State: Equatable {
    public var isLoading = false
    public var items: [HomeItem] = []
    public var error: HomeError?
    public var searchText = ""
    public var selectedItem: HomeItem?
    
    public init() {}
    
    public var filteredItems: [HomeItem] {
      if searchText.isEmpty {
        return items
      } else {
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
      }
    }
  }
  
  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    case refresh
    case loadItems
    case itemsLoaded([HomeItem])
    case itemsLoadFailed(HomeError)
    case itemTapped(HomeItem)
    case searchTextChanged(String)
    case clearError
  }
  
  @Dependency(\.networkClient) var networkClient
  
  public init() {}
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding(\.searchText):
        return .none
        
      case .binding:
        return .none
        
      case .onAppear:
        guard state.items.isEmpty && !state.isLoading else { return .none }
        return .send(.loadItems)
        
      case .refresh:
        state.error = nil
        return .send(.loadItems)
        
      case .loadItems:
        state.isLoading = true
        state.error = nil
        
        return .run { send in
          do {
            let items = try await loadHomeItems()
            await send(.itemsLoaded(items))
          } catch {
            await send(.itemsLoadFailed(.networkError(error.localizedDescription)))
          }
        }
        
      case let .itemsLoaded(items):
        state.isLoading = false
        state.items = items
        return .none
        
      case let .itemsLoadFailed(error):
        state.isLoading = false
        state.error = error
        return .none
        
      case let .itemTapped(item):
        state.selectedItem = item
        // Handle item selection - navigate to detail view, etc.
        return .none
        
      case let .searchTextChanged(text):
        state.searchText = text
        return .none
        
      case .clearError:
        state.error = nil
        return .none
      }
    }
  }
}

// MARK: - Models

public struct HomeItem: Equatable, Identifiable, Sendable {
  public let id: String
  public let title: String
  public let subtitle: String?
  public let imageURL: String?
  public let category: Category
  public let createdAt: Date
  
  public init(
    id: String,
    title: String,
    subtitle: String? = nil,
    imageURL: String? = nil,
    category: Category,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.imageURL = imageURL
    self.category = category
    self.createdAt = createdAt
  }
  
  public enum Category: String, CaseIterable, Sendable {
    case featured = "Featured"
    case recent = "Recent"
    case popular = "Popular"
    case recommended = "Recommended"
    
    public var systemImage: String {
      switch self {
      case .featured: return "star.fill"
      case .recent: return "clock.fill"
      case .popular: return "flame.fill"
      case .recommended: return "heart.fill"
      }
    }
  }
}

public enum HomeError: Error, Equatable, LocalizedError, Sendable {
  case networkError(String)
  case decodingError(String)
  case noData
  case unauthorized
  case serverError
  
  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "Network error: \(message)"
    case .decodingError(let message):
      return "Data parsing error: \(message)"
    case .noData:
      return "No data available"
    case .unauthorized:
      return "You are not authorized to access this content"
    case .serverError:
      return "Server error occurred"
    }
  }
}

// MARK: - API Response Models

private struct HomeItemResponse: Codable {
  let id: String
  let title: String
  let subtitle: String?
  let imageURL: String?
  let category: String
  let createdAt: String
}

private struct HomeResponse: Codable {
  let items: [HomeItemResponse]
  let total: Int
}

// MARK: - Private API Functions

private func loadHomeItems() async throws -> [HomeItem] {
  // This is a mock implementation
  // In a real app, you would make an actual API call
  
  // Simulate network delay
  try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
  
  // Return mock data
  return [
    HomeItem(
      id: "1",
      title: "Welcome to TCA Template",
      subtitle: "Get started with your new app",
      category: .featured
    ),
    HomeItem(
      id: "2",
      title: "Feature Example",
      subtitle: "This is an example feature",
      category: .recent
    ),
    HomeItem(
      id: "3",
      title: "Popular Content",
      subtitle: "Most viewed content",
      category: .popular
    ),
    HomeItem(
      id: "4",
      title: "Recommended for You",
      subtitle: "Based on your preferences",
      category: .recommended
    ),
  ]
}

// MARK: - Real API Implementation (commented out)

/*
private func loadHomeItems() async throws -> [HomeItem] {
  let request = try RequestBuilder(baseURL: URL(string: "https://api.example.com")!)
    .path("/home/items")
    .method(.GET)
    .acceptJSON()
    .build()
  
  let response: HomeResponse = try await networkClient.requestDecodable(request, as: HomeResponse.self)
  
  let dateFormatter = ISO8601DateFormatter()
  
  return response.items.compactMap { item in
    guard let category = HomeItem.Category(rawValue: item.category),
          let date = dateFormatter.date(from: item.createdAt) else {
      return nil
    }
    
    return HomeItem(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      imageURL: item.imageURL,
      category: category,
      createdAt: date
    )
  }
}
*/
