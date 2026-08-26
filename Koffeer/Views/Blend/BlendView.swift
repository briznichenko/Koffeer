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

    // Injected ViewModel
    @StateObject private var viewModel: BlendViewModel

    let onDismiss: (CoffeeBlend) -> Void

    init(
        blend: CoffeeBlend,
        blendsRepository: BlendsRepository? = nil,
        textRecognitionService: TextRecognitionService? = nil,
        onDismiss: @escaping (CoffeeBlend) -> Void
    ) {
        let repo = blendsRepository ?? {
            fatalError("BlendView requires a BlendsRepository injected.")
        }()

        let textService = textRecognitionService ?? VisionTextRecognitionService()

        _viewModel = StateObject(wrappedValue: BlendViewModel(
            blend: blend,
            blendsRepository: repo,
            textRecognition: textService
        ))
        self.onDismiss = onDismiss
    }

    var body: some View {
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

            // TextEditor with placeholder overlay
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

            VStack {
                Text("Sourness")
                    .font(.title)
                HStack {
                    StarRatingView(rating: $viewModel.sourness)
                    Text("\(viewModel.sourness)/5")
                        .font(.headline)
                }
            }
            VStack {
                Text("Sweetness")
                    .font(.title)
                HStack {
                    StarRatingView(rating: $viewModel.sweetness)
                    Text("\(viewModel.sweetness)/5")
                        .font(.headline)
                }
            }
            VStack {
                Text("Bitterness")
                    .font(.title)
                HStack {
                    StarRatingView(rating: $viewModel.bitterness)
                    Text("\(viewModel.bitterness)/5")
                        .font(.headline)
                }
            }
            Divider()
            Spacer(minLength: 50)
            Button("Done") {
                Task {
                    await viewModel.saveChanges()
                    onDismiss(viewModel.blend)
                    dismiss()
                }
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

