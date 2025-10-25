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
    
    @State var blend: CoffeeBlend
    let onDismiss: (CoffeeBlend) -> Void
    
    @State private var showBlendPhotoPicker: Bool = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var recognizedText = ""
    
    private var bindingForName: Binding<String> {
        Binding(
            get: { recognizedText.isEmpty ? blend.name : recognizedText },
            set: { newValue in
                if recognizedText.isEmpty {
                    blend.name = newValue
                } else {
                    recognizedText = newValue
                }
            }
        )
    }
    
    var body: some View {
        ScrollView {
            Image(uiImage: avatarUIImage(from: blend.imageData))
                .resizable()
                .padding(.top)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(Rectangle())
                .onTapGesture {
                    showBlendPhotoPicker = true
                }
                .photosPicker(isPresented: $showBlendPhotoPicker, selection: $selectedPhoto, matching: .images)
                .onChange(of: selectedPhoto) { _, newPhoto in
                    guard let newPhoto else { return }
                    Task {
                        if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                blend.imageData = data
                            }
                        }
                        // Clean up
                        selectedPhoto = nil
                    }
                }
            TextField("Enter name", text: bindingForName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            VStack(spacing: 20) {
                Text("Sourness")
                    .font(.title)
                
                StarRatingView(rating: $blend.sourness)
                
                Text("\(blend.sourness)/5")
                    .font(.headline)
            }
            VStack(spacing: 20) {
                Text("Sweetness")
                    .font(.title)
                
                StarRatingView(rating: $blend.sweetness)
                
                Text("\(blend.sweetness)/5")
                    .font(.headline)
            }
            VStack(spacing: 20) {
                Text("Bitterness")
                    .font(.title)
                
                StarRatingView(rating: $blend.bitterness)
                
                Text("\(blend.bitterness)/5")
                    .font(.headline)
            }
            Spacer()
            Button("Extract Text") {
                TextRecognition.recognizeText(from: avatarUIImage(from: blend.imageData)) { text in
                    DispatchQueue.main.async {
                        recognizedText = text
                    }
                }
            }
            Spacer()
            Button("Done") {
                onDismiss(blend)
                dismiss()
            }
        }
    }
}

// MARK: - Helpers (scoped to this file)
private func avatarUIImage(from data: Data?) -> UIImage {
    if let data, let image = UIImage(data: data) {
        return image
    }
    let dynamicColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    return UIImage(color: dynamicColor) ?? UIImage()
}
