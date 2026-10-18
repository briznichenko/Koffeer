import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class BlendViewModel: ObservableObject {
    private let blendsRepository: BlendsRepository
    private let textRecognition: TextRecognitionService

    @Published private(set) var blend: CoffeeBlend

    @Published var name: String
    @Published var detailsText: String
    @Published var sweetness: Int
    @Published var sourness: Int
    @Published var bitterness: Int
    @Published var imageData: Data?

    @Published var isPhotoPickerPresented: Bool = false
    @Published var selectedPhotoItem: PhotosPickerItem?

    init(
        blend: CoffeeBlend,
        blendsRepository: BlendsRepository,
        textRecognition: TextRecognitionService
    ) {
        self.blend = blend
        self.blendsRepository = blendsRepository
        self.textRecognition = textRecognition

        self.name = blend.name
        self.detailsText = blend.details ?? ""
        self.sweetness = blend.sweetness
        self.sourness = blend.sourness
        self.bitterness = blend.bitterness
        self.imageData = blend.imageData
    }

    func saveChanges() async {
        blend.name = name
        blend.details = detailsText.isEmpty ? nil : detailsText
        blend.sweetness = sweetness
        blend.sourness = sourness
        blend.bitterness = bitterness
        blend.imageData = imageData
        do {
            try await blendsRepository.update(blend)
        } catch {
            print("Failed to save blend: \(error)")
        }
    }

    func handleSelectedPhotoChanged() {
        guard let item = selectedPhotoItem else { return }
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.imageData = data
                    }
                }
            } catch {
                print("Failed to load photo: \(error)")
            }
            await MainActor.run {
                self.selectedPhotoItem = nil
            }
        }
    }

    func extractTextFromImage() {
        Task {
            let image = avatarUIImage(from: imageData)
            let text = await textRecognition.recognizeText(from: image)
            await MainActor.run {
                self.detailsText = text
            }
        }
    }
}

