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

    @Published private(set) var isSaving = false
    @Published private(set) var saveErrorMessage: String?

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

    func saveChanges() async -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        saveErrorMessage = nil
        defer { isSaving = false }

        let original = (
            name: blend.name,
            details: blend.details,
            sweetness: blend.sweetness,
            sourness: blend.sourness,
            bitterness: blend.bitterness,
            imageData: blend.imageData
        )

        blend.name = name
        blend.details = detailsText.isEmpty ? nil : detailsText
        blend.sweetness = sweetness
        blend.sourness = sourness
        blend.bitterness = bitterness
        blend.imageData = imageData
        do {
            try await blendsRepository.update(blend)
            return true
        } catch {
            blend.name = original.name
            blend.details = original.details
            blend.sweetness = original.sweetness
            blend.sourness = original.sourness
            blend.bitterness = original.bitterness
            blend.imageData = original.imageData
            saveErrorMessage = "Couldn’t save this blend. Your edits are still here. Try again."
            return false
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

