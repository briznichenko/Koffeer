import Foundation
import SwiftData

final class SwiftDataItemsRepository: ItemsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchItems() async throws -> [Item] {
        try context.fetch(FetchDescriptor<Item>())
    }

    func insert(_ item: Item) async throws {
        context.insert(item)
        try context.save()
    }

    func update(_ item: Item) async throws {
        try context.save()
    }

    func delete(_ item: Item) async throws {
        context.delete(item)
        try context.save()
    }
}

