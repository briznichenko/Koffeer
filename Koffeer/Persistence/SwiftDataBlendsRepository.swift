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
        // With SwiftData, changes on a managed model are tracked automatically.
        // Just save the context.
        try context.save()
    }

    func delete(_ blend: CoffeeBlend) async throws {
        context.delete(blend)
        try context.save()
    }
}

