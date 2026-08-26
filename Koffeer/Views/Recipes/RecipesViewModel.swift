import Foundation
import SwiftUI
import Combine

@MainActor
final class RecipesViewModel: ObservableObject {
    private let itemsRepository: ItemsRepository

    @Published var items: [Item] = []
    @Published var selectedItem: Item?

    init(itemsRepository: ItemsRepository) {
        self.itemsRepository = itemsRepository
    }

    func load() async {
        do {
            items = try await itemsRepository.fetchItems()
        } catch {
            print("Failed to fetch items: \(error)")
            items = []
        }
    }

    func addItem() async {
        let newItem = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
        do {
            try await itemsRepository.insert(newItem)
            await load()
        } catch {
            print("Failed to insert item: \(error)")
        }
    }

    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let item = items[index]
            do {
                try await itemsRepository.delete(item)
            } catch {
                print("Failed to delete item: \(error)")
            }
        }
        await load()
    }
}

