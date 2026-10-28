import Foundation
import Combine

@MainActor
final class RecipesViewModel: ObservableObject {
    private let itemsRepository: ItemsRepository

    @Published var items: [Item] = []
    @Published var selectedItem: Item?
    @Published private(set) var isLoading = false
    @Published private(set) var isMutating = false
    @Published private(set) var loadErrorMessage: String?
    @Published private(set) var operationErrorMessage: String?

    init(itemsRepository: ItemsRepository) {
        self.itemsRepository = itemsRepository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await itemsRepository.fetchItems()
            loadErrorMessage = nil
        } catch {
            loadErrorMessage = "Couldn’t load brews. Try again."
        }
    }

    func addItem() async {
        guard !isMutating else { return }
        isMutating = true
        operationErrorMessage = nil
        defer { isMutating = false }
        let newItem = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
        do {
            try await itemsRepository.insert(newItem)
            await load()
        } catch {
            operationErrorMessage = "Couldn’t add the brew. Try adding it again."
        }
    }

    func delete(at offsets: IndexSet) async {
        guard !isMutating else { return }
        isMutating = true
        operationErrorMessage = nil
        defer { isMutating = false }
        let selected = offsets.compactMap { items.indices.contains($0) ? items[$0] : nil }
        for item in selected {
            do {
                try await itemsRepository.delete(item)
            } catch {
                operationErrorMessage = "Couldn’t delete the brew. Try deleting it again."
                break
            }
        }
        await load()
    }

    func assignBlend(_ blend: CoffeeBlend, to item: Item) async {
        guard !isMutating else { return }
        isMutating = true
        operationErrorMessage = nil
        defer { isMutating = false }
        let original = item.coffeeBlend
        item.coffeeBlend = blend
        do {
            try await itemsRepository.update(item)
            selectedItem = nil
        } catch {
            item.coffeeBlend = original
            operationErrorMessage = "Couldn’t assign the blend. Choose it again to retry."
        }
    }
}

