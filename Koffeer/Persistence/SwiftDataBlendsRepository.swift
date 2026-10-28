import Foundation
import SwiftData

final class SwiftDataBlendsRepository: BlendsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchBlends() async throws -> [CoffeeBlend] {
        try context.fetch(FetchDescriptor<CoffeeBlend>())
    }

    func insert(_ blend: CoffeeBlend) async throws {
        context.insert(blend)
        try context.save()
    }

    func update(_ blend: CoffeeBlend) async throws {
        guard blend.modelContext === context else {
            throw PersistenceError.modelNotInContext
        }
        try context.save()
    }

    func delete(_ blend: CoffeeBlend) async throws {
        guard blend.modelContext === context else {
            throw PersistenceError.modelNotInContext
        }
        let blendID = blend.persistentModelID
        let linkedBrews = FetchDescriptor<Item>(predicate: #Predicate {
            $0.coffeeBlend.persistentModelID == blendID
        })
        guard try context.fetchCount(linkedBrews) == 0 else {
            throw PersistenceError.blendInUse
        }
        context.delete(blend)
        try context.save()
    }
}

