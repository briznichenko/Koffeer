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
    
    var body: some View {
        ScrollView {
            Image(uiImage: avatarUIImage(from: blend.imageData))
                .resizable()
                .padding(.top)
                .aspectRatio(1.0, contentMode: .fit)
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
            TextField("Enter name", text: $blend.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextEditor(text: Binding(
                get: { blend.details ?? "Blend details" },
                set: { blend.details = $0.isEmpty ? "Blend details" : $0 }
            ))
            Button("Extract Text") {
                TextRecognition.recognizeText(from: avatarUIImage(from: blend.imageData)) { text in
                    DispatchQueue.main.async {
                        blend.details = text.isEmpty ? nil : text
                    }
                }
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
                    StarRatingView(rating: $blend.sourness)
                    Text("\(blend.sourness)/5")
                        .font(.headline)
                }
            }
            VStack {
                Text("Sweetness")
                    .font(.title)
                HStack {
                    StarRatingView(rating: $blend.sweetness)
                    Text("\(blend.sweetness)/5")
                        .font(.headline)
                }
            }
            VStack {
                Text("Bitterness")
                    .font(.title)
                HStack {
                    StarRatingView(rating: $blend.bitterness)
                    Text("\(blend.bitterness)/5")
                        .font(.headline)
                }
            }
            Divider()
            Spacer(minLength: 50)
            Button("Done") {
                onDismiss(blend)
                dismiss()
            }
        }
    }
}

#Preview {
    BlendView(blend: .init(name: "Name"), onDismiss: { _ in })
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
