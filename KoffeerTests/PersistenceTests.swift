import Foundation
import SwiftData
import Testing
@testable import Koffeer

@MainActor
struct PersistenceTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeBlend.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test
    func assignedBlendCanBeReadFromNewContext() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let item = Item(timestamp: .now, type: .v60, steps: [30])
        let blend = CoffeeBlend(name: "Assigned")
        context.insert(item)
        context.insert(blend)
        try context.save()
        let viewModel = RecipesViewModel(itemsRepository: SwiftDataItemsRepository(context: context))

        await viewModel.assignBlend(blend, to: item)

        let readContext = ModelContext(container)
        let stored = try readContext.fetch(FetchDescriptor<Item>())
        #expect(stored.first?.coffeeBlend.name == "Assigned")
    }

    @Test
    func linkedBlendDeletionIsRejectedAndBrewIsPreserved() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let item = Item(timestamp: .now, type: .v60, steps: [30])
        context.insert(item)
        try context.save()
        let repository = SwiftDataBlendsRepository(context: context)

        await #expect(throws: PersistenceError.blendInUse) {
            try await repository.delete(item.coffeeBlend)
        }

        let readContext = ModelContext(container)
        #expect(try readContext.fetchCount(FetchDescriptor<CoffeeBlend>()) == 1)
        #expect(try readContext.fetchCount(FetchDescriptor<Item>()) == 1)
    }

    @Test
    func unlinkedBlendCanBeDeleted() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let blend = CoffeeBlend(name: "Unused")
        let repository = SwiftDataBlendsRepository(context: context)
        try await repository.insert(blend)

        try await repository.delete(blend)

        #expect(try ModelContext(container).fetchCount(FetchDescriptor<CoffeeBlend>()) == 0)
    }

    @Test
    func updatesRejectModelsOwnedByAnotherContext() async throws {
        let container = try makeContainer()
        let owner = ModelContext(container)
        let other = ModelContext(container)
        let item = Item(timestamp: .now, type: .v60, steps: [30])
        owner.insert(item)
        try owner.save()

        await #expect(throws: PersistenceError.modelNotInContext) {
            try await SwiftDataItemsRepository(context: other).update(item)
        }
        await #expect(throws: PersistenceError.modelNotInContext) {
            try await SwiftDataBlendsRepository(context: other).update(item.coffeeBlend)
        }
    }
}
