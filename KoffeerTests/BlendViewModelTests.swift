import Foundation
import SwiftData
import Testing
import UIKit
@testable import Koffeer

@MainActor
private final class EditorBlendsRepository: BlendsRepository {
    var shouldFail = false
    var updateCount = 0
    var suspendUpdate = false
    var onUpdate: (() -> Void)?
    var continuation: CheckedContinuation<Void, Never>?

    func fetchBlends() async throws -> [CoffeeBlend] { [] }
    func insert(_ blend: CoffeeBlend) async throws {}
    func delete(_ blend: CoffeeBlend) async throws {}

    func update(_ blend: CoffeeBlend) async throws {
        updateCount += 1
        if suspendUpdate {
            await withCheckedContinuation {
                continuation = $0
                onUpdate?()
            }
        }
        if shouldFail {
            throw EditorSaveError.failed
        }
    }
}

private enum EditorSaveError: Error {
    case failed
}

private struct EditorTextRecognition: TextRecognitionService {
    func recognizeText(from image: UIImage?) async -> String { "" }
}

@MainActor
struct BlendViewModelTests {
    private func makeViewModel(
        blend: CoffeeBlend,
        repository: EditorBlendsRepository
    ) -> BlendViewModel {
        BlendViewModel(
            blend: blend,
            blendsRepository: repository,
            textRecognition: EditorTextRecognition()
        )
    }

    @Test
    func successfulSaveAppliesAllDraftFields() async {
        let blend = CoffeeBlend(name: "Original")
        let repository = EditorBlendsRepository()
        let viewModel = makeViewModel(blend: blend, repository: repository)
        viewModel.name = "Edited"
        viewModel.detailsText = "Chocolate"
        viewModel.sweetness = 4
        viewModel.sourness = 2
        viewModel.bitterness = 3
        viewModel.imageData = Data([1, 2])

        let saved = await viewModel.saveChanges()

        #expect(saved)
        #expect(repository.updateCount == 1)
        #expect(blend.name == "Edited")
        #expect(blend.details == "Chocolate")
        #expect(blend.sweetness == 4)
        #expect(blend.sourness == 2)
        #expect(blend.bitterness == 3)
        #expect(blend.imageData == Data([1, 2]))
        #expect(viewModel.saveErrorMessage == nil)
        #expect(!viewModel.isSaving)
    }

    @Test
    func failureRestoresAllModelFieldsAndPreservesDraft() async {
        let blend = CoffeeBlend(name: "Original", sweetness: 1, sourness: 2, bitterness: 3, imageData: Data([0]))
        blend.details = "Original details"
        let repository = EditorBlendsRepository()
        repository.shouldFail = true
        let viewModel = makeViewModel(blend: blend, repository: repository)
        viewModel.name = "Edited"
        viewModel.detailsText = "Edited details"
        viewModel.sweetness = 5
        viewModel.sourness = 4
        viewModel.bitterness = 1
        viewModel.imageData = Data([9])

        let saved = await viewModel.saveChanges()

        #expect(!saved)
        #expect(blend.name == "Original")
        #expect(blend.details == "Original details")
        #expect(blend.sweetness == 1)
        #expect(blend.sourness == 2)
        #expect(blend.bitterness == 3)
        #expect(blend.imageData == Data([0]))
        #expect(viewModel.name == "Edited")
        #expect(viewModel.detailsText == "Edited details")
        #expect(viewModel.sweetness == 5)
        #expect(viewModel.sourness == 4)
        #expect(viewModel.bitterness == 1)
        #expect(viewModel.imageData == Data([9]))
        #expect(viewModel.saveErrorMessage != nil)
        #expect(!viewModel.isSaving)
    }

    @Test
    func retrySavesDraftAndClearsError() async {
        let blend = CoffeeBlend(name: "Original")
        let repository = EditorBlendsRepository()
        repository.shouldFail = true
        let viewModel = makeViewModel(blend: blend, repository: repository)
        viewModel.name = "Edited"
        viewModel.detailsText = ""
        _ = await viewModel.saveChanges()
        repository.shouldFail = false

        let saved = await viewModel.saveChanges()

        #expect(saved)
        #expect(blend.name == "Edited")
        #expect(blend.details == nil)
        #expect(viewModel.saveErrorMessage == nil)
        #expect(repository.updateCount == 2)
    }

    @Test
    func overlappingSaveIsRejected() async {
        let repository = EditorBlendsRepository()
        repository.suspendUpdate = true
        let viewModel = makeViewModel(blend: CoffeeBlend(name: "Original"), repository: repository)
        var firstSave: Task<Bool, Never>?
        await withCheckedContinuation { started in
            repository.onUpdate = { started.resume() }
            firstSave = Task { await viewModel.saveChanges() }
        }

        #expect(viewModel.isSaving)
        let secondSaved = await viewModel.saveChanges()
        #expect(!secondSaved)
        #expect(repository.updateCount == 1)
        repository.continuation?.resume()
        repository.continuation = nil
        let firstSaved = await firstSave?.value
        #expect(firstSaved == true)
        #expect(!viewModel.isSaving)
    }

    @Test
    func laterContextSaveDoesNotPersistFailedEditOrDiscardUnrelatedChanges() async throws {
        let container = try ModelContainer(
            for: CoffeeBlend.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let blend = CoffeeBlend(name: "Original")
        let unrelated = CoffeeBlend(name: "Other")
        context.insert(blend)
        context.insert(unrelated)
        try context.save()
        unrelated.details = "Keep this change"
        let repository = EditorBlendsRepository()
        repository.shouldFail = true
        let viewModel = makeViewModel(blend: blend, repository: repository)
        viewModel.name = "Failed edit"

        _ = await viewModel.saveChanges()
        try context.save()

        let readContext = ModelContext(container)
        let stored = try readContext.fetch(FetchDescriptor<CoffeeBlend>())
        #expect(stored.contains { $0.name == "Original" })
        #expect(!stored.contains { $0.name == "Failed edit" })
        #expect(stored.first { $0.name == "Other" }?.details == "Keep this change")
    }
}
