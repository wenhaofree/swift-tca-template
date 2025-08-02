import ComposableArchitecture
import HomeCore
import Testing

@MainActor
struct HomeCoreTests {

  @Test
  func initialState() async {
    let state = Home.State()
    #expect(state.isLoading == false)
    #expect(state.items.isEmpty)
    #expect(state.error == nil)
    #expect(state.searchText == "")
  }

  @Test
  func clearError() async {
    var initialState = Home.State()
    initialState.error = .networkError("Test error")

    let store = TestStore(initialState: initialState) {
      Home()
    }

    await store.send(.clearError) {
      $0.error = nil
    }
  }

  @Test
  func homeItemEquality() {
    let item1 = HomeItem(
      id: "1",
      title: "Test",
      category: .featured
    )
    let item2 = HomeItem(
      id: "1",
      title: "Test",
      category: .featured
    )
    let item3 = HomeItem(
      id: "2",
      title: "Test",
      category: .featured
    )

    #expect(item1 == item2)
    #expect(item1 != item3)
  }

  @Test
  func homeErrorLocalizedDescription() {
    let networkError = HomeError.networkError("Connection failed")
    let decodingError = HomeError.decodingError("Invalid JSON")
    let noDataError = HomeError.noData
    let unauthorizedError = HomeError.unauthorized
    let serverError = HomeError.serverError

    #expect(networkError.localizedDescription == "Network error: Connection failed")
    #expect(decodingError.localizedDescription == "Data parsing error: Invalid JSON")
    #expect(noDataError.localizedDescription == "No data available")
    #expect(unauthorizedError.localizedDescription == "You are not authorized to access this content")
    #expect(serverError.localizedDescription == "Server error occurred")
  }

  @Test
  func homeItemCategorySystemImages() {
    #expect(HomeItem.Category.featured.systemImage == "star.fill")
    #expect(HomeItem.Category.recent.systemImage == "clock.fill")
    #expect(HomeItem.Category.popular.systemImage == "flame.fill")
    #expect(HomeItem.Category.recommended.systemImage == "heart.fill")
  }

  @Test
  func filteredItems() {
    let items = [
      HomeItem(id: "1", title: "Swift Programming", category: .featured),
      HomeItem(id: "2", title: "iOS Development", category: .recent),
      HomeItem(id: "3", title: "SwiftUI Tutorial", category: .popular)
    ]

    var state = Home.State()
    state.items = items

    // Test empty search
    state.searchText = ""
    #expect(state.filteredItems.count == 3)

    // Test search with results
    state.searchText = "Swift"
    #expect(state.filteredItems.count == 2)
    #expect(state.filteredItems.allSatisfy { $0.title.contains("Swift") })

    // Test search with no results
    state.searchText = "Android"
    #expect(state.filteredItems.isEmpty)
  }
}
