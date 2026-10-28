//
//  BlendView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI
import PhotosUI

struct BlendView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: BlendViewModel

    let onDismiss: (CoffeeBlend) -> Void

    init(
        blend: CoffeeBlend,
        blendsRepository: BlendsRepository,
        textRecognitionService: TextRecognitionService,
        onDismiss: @escaping (CoffeeBlend) -> Void
    ) {
        _viewModel = State(initialValue: BlendViewModel(
            blend: blend,
            blendsRepository: blendsRepository,
            textRecognition: textRecognitionService
        ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            Image(uiImage: avatarUIImage(from: viewModel.imageData))
                .resizable()
                .padding(.top)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Rectangle())
                .onTapGesture {
                    viewModel.isPhotoPickerPresented = true
                }
                .photosPicker(isPresented: $viewModel.isPhotoPickerPresented,
                              selection: $viewModel.selectedPhotoItem,
                              matching: .images)
                .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                    viewModel.handleSelectedPhotoChanged()
                }

            TextField("Enter name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $viewModel.detailsText)
                .frame(minHeight: 120)
                .padding(.horizontal)
                .overlay(alignment: .topLeading) {
                    if viewModel.detailsText.isEmpty {
                        Text("Blend details")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary)
                )
                .padding(.bottom)

            Button("Extract Text") {
                viewModel.extractTextFromImage()
            }
            .foregroundStyle(.foreground)
            .background(Color.blue)
            .padding(.horizontal)
            .clipShape(.ellipse)

            Divider()

            ratingSection("Sourness", rating: $viewModel.sourness)
            ratingSection("Sweetness", rating: $viewModel.sweetness)
            ratingSection("Bitterness", rating: $viewModel.bitterness)
            Divider()
            Spacer(minLength: 50)
            if let message = viewModel.saveErrorMessage {
                Text(message)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            if viewModel.isSaving {
                ProgressView("Saving…")
            }
            Button(viewModel.saveErrorMessage == nil ? "Done" : "Retry Save") {
                Task {
                    if await viewModel.saveChanges() {
                        onDismiss(viewModel.blend)
                        dismiss()
                    }
                }
            }
        }
        .disabled(viewModel.isSaving)
        .interactiveDismissDisabled(viewModel.isSaving)
    }

    private func ratingSection(_ title: LocalizedStringKey, rating: Binding<Int>) -> some View {
        VStack {
            Text(title)
                .font(.title)
            HStack {
                StarRatingView(rating: rating)
                Text("\(rating.wrappedValue)/5")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    struct PreviewRepo: BlendsRepository {
        func fetchBlends() async throws -> [CoffeeBlend] { [] }
        func insert(_ blend: CoffeeBlend) async throws {}
        func update(_ blend: CoffeeBlend) async throws {}
        func delete(_ blend: CoffeeBlend) async throws {}
    }

    return BlendView(
        blend: .init(name: "Name"),
        blendsRepository: PreviewRepo(),
        textRecognitionService: VisionTextRecognitionService(),
        onDismiss: { _ in }
    )
}
