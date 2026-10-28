import Foundation
import Testing
@testable import Koffeer

@MainActor
private final class RecipeItemsRepository: ItemsRepository {
    var items: [Item] = []
    var failFetch = false
    var failUpdate = false
    var updateCount = 0

    func fetchItems() async throws -> [Item] {
        if failFetch { throw RecipeRepositoryError.failed }
        return items
    }

    func insert(_ item: Item) async throws { items.append(item) }

    func update(_ item: Item) async throws {
        updateCount += 1
        if failUpdate { throw RecipeRepositoryError.failed }
    }

    func delete(_ item: Item) async throws {
        items.removeAll { $0 === item }
    }
}

private enum RecipeRepositoryError: Error {
    case failed
}

@MainActor
struct RecipesViewModelTests {
    @Test
    func failedRefreshPreservesItemsAndRetryClearsError() async {
        let repository = RecipeItemsRepository()
        let item = Item(timestamp: .now, type: .v60, steps: [30])
        repository.items = [item]
        let viewModel = RecipesViewModel(itemsRepository: repository)
        await viewModel.load()
        repository.failFetch = true

        await viewModel.load()

        #expect(viewModel.items.first === item)
        #expect(viewModel.loadErrorMessage != nil)
        #expect(!viewModel.isLoading)
        repository.failFetch = false
        await viewModel.load()
        #expect(viewModel.loadErrorMessage == nil)
    }

    @Test
    func failedAssignmentRestoresBlendAndKeepsSelectionForRetry() async {
        let repository = RecipeItemsRepository()
        repository.failUpdate = true
        let item = Item(timestamp: .now, type: .v60, steps: [30])
        let original = item.coffeeBlend
        let replacement = CoffeeBlend(name: "Replacement")
        let viewModel = RecipesViewModel(itemsRepository: repository)
        viewModel.selectedItem = item

        await viewModel.assignBlend(replacement, to: item)

        #expect(item.coffeeBlend === original)
        #expect(viewModel.selectedItem === item)
        #expect(viewModel.operationErrorMessage != nil)
        repository.failUpdate = false

        await viewModel.assignBlend(replacement, to: item)

        #expect(item.coffeeBlend === replacement)
        #expect(viewModel.selectedItem == nil)
        #expect(viewModel.operationErrorMessage == nil)
        #expect(repository.updateCount == 2)
    }

    @Test
    func addAndDeleteReloadItems() async {
        let repository = RecipeItemsRepository()
        let viewModel = RecipesViewModel(itemsRepository: repository)

        await viewModel.addItem()
        #expect(viewModel.items.count == 1)

        await viewModel.delete(at: IndexSet(integer: 0))
        #expect(viewModel.items.isEmpty)
        #expect(repository.items.isEmpty)
    }
}
