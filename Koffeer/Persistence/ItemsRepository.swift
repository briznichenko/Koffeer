import Foundation

@MainActor
protocol ItemsRepository {
    func fetchItems() async throws -> [Item]
    func insert(_ item: Item) async throws
    func update(_ item: Item) async throws
    func delete(_ item: Item) async throws
}

