import Foundation
import Testing
@testable import Koffeer

@MainActor
private final class FakeBlendsRepository: BlendsRepository {
    var blends: [CoffeeBlend] = []
    var insertCallCount = 0
    var deleteCallCount = 0
    var shouldThrowOnFetch = false

    func fetchBlends() async throws -> [CoffeeBlend] {
        if shouldThrowOnFetch {
            throw FakeRepositoryError.fetchFailed
        }
        return blends
    }

    func insert(_ blend: CoffeeBlend) async throws {
        insertCallCount += 1
        blends.append(blend)
    }

    func update(_ blend: CoffeeBlend) async throws {}

    func delete(_ blend: CoffeeBlend) async throws {
        deleteCallCount += 1
        blends.removeAll { $0 === blend }
    }
}

private enum FakeRepositoryError: Error {
    case fetchFailed
}

@MainActor
struct BlendsViewModelTests {
    @Test
    func loadPopulatesBlendsFromRepository() async {
        let repository = FakeBlendsRepository()
        repository.blends = [CoffeeBlend(name: "Ethiopia"), CoffeeBlend(name: "Colombia")]
        let viewModel = BlendsViewModel(blendsRepository: repository)

        await viewModel.load()

        #expect(viewModel.blends.map(\.name) == ["Ethiopia", "Colombia"])
    }

    @Test
    func loadFailureResultsInEmptyBlends() async {
        let repository = FakeBlendsRepository()
        repository.shouldThrowOnFetch = true
        let viewModel = BlendsViewModel(blendsRepository: repository)
        viewModel.blends = [CoffeeBlend(name: "Stale")]

        await viewModel.load()

        #expect(viewModel.blends.isEmpty)
    }

    @Test
    func addBlendInsertsAndReloads() async {
        let repository = FakeBlendsRepository()
        let viewModel = BlendsViewModel(blendsRepository: repository)

        await viewModel.addBlend()

        #expect(repository.insertCallCount == 1)
        #expect(viewModel.blends.map(\.name) == ["New Blend"])
    }

    @Test
    func deleteRemovesBlendAtOffsetAndReloads() async {
        let repository = FakeBlendsRepository()
        let blendToKeep = CoffeeBlend(name: "Keep")
        let blendToDelete = CoffeeBlend(name: "Delete")
        repository.blends = [blendToKeep, blendToDelete]
        let viewModel = BlendsViewModel(blendsRepository: repository)
        await viewModel.load()

        await viewModel.delete(at: IndexSet(integer: 1))

        #expect(repository.deleteCallCount == 1)
        #expect(viewModel.blends.map(\.name) == ["Keep"])
    }
}
