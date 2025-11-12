import Foundation
import SwiftUI
import Combine

@MainActor
final class BlendsViewModel: ObservableObject {
    private let blendsRepository: BlendsRepository

    @Published var blends: [CoffeeBlend] = []
    @Published var selectedBlend: CoffeeBlend?

    init(blendsRepository: BlendsRepository) {
        self.blendsRepository = blendsRepository
    }

    func load() async {
        do {
            blends = try await blendsRepository.fetchBlends()
        } catch {
            print("Failed to fetch blends: \(error)")
            blends = []
        }
    }

    func addBlend() async {
        let newBlend = CoffeeBlend(name: "New Blend")
        do {
            try await blendsRepository.insert(newBlend)
            await load()
        } catch {
            print("Failed to insert blend: \(error)")
        }
    }

    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let blend = blends[index]
            do {
                try await blendsRepository.delete(blend)
            } catch {
                print("Failed to delete blend: \(error)")
            }
        }
        await load()
    }
}

