import Foundation
import Observation

@Observable
@MainActor
final class BlendsViewModel {
    private let blendsRepository: BlendsRepository

    var blends: [CoffeeBlend] = []
    var selectedBlend: CoffeeBlend?
    private(set) var isLoading = false
    private(set) var isMutating = false
    private(set) var loadErrorMessage: String?
    private(set) var operationErrorMessage: String?

    init(blendsRepository: BlendsRepository) {
        self.blendsRepository = blendsRepository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            blends = try await blendsRepository.fetchBlends()
            loadErrorMessage = nil
        } catch {
            loadErrorMessage = "Couldn’t load blends. Try again."
        }
    }

    func addBlend() async {
        guard !isMutating else { return }
        isMutating = true
        operationErrorMessage = nil
        defer { isMutating = false }
        let newBlend = CoffeeBlend(name: "New Blend")
        do {
            try await blendsRepository.insert(newBlend)
            await load()
        } catch {
            operationErrorMessage = "Couldn’t add the blend. Try adding it again."
        }
    }

    func delete(at offsets: IndexSet) async {
        guard !isMutating else { return }
        isMutating = true
        operationErrorMessage = nil
        defer { isMutating = false }
        let selected = offsets.compactMap { blends.indices.contains($0) ? blends[$0] : nil }
        for blend in selected {
            do {
                try await blendsRepository.delete(blend)
            } catch {
                operationErrorMessage = (error as? PersistenceError)?.errorDescription
                    ?? "Couldn’t delete the blend. Try deleting it again."
                break
            }
        }
        await load()
    }
}

