//
//  BlendsView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI

struct BlendsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: BlendsViewModel

    let blendsRepository: BlendsRepository
    let textRecognitionService: TextRecognitionService
    let onDismiss: ((CoffeeBlend) -> Void)?

    init(
        blendsRepository: BlendsRepository,
        textRecognitionService: TextRecognitionService,
        onDismiss: ((CoffeeBlend) -> Void)?
    ) {
        _viewModel = StateObject(wrappedValue: BlendsViewModel(blendsRepository: blendsRepository))
        self.blendsRepository = blendsRepository
        self.textRecognitionService = textRecognitionService
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.blends) { blend in
                    NavigationLink {
                        Button("Done") {
                            onDismiss?(blend)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(uiImage: avatarUIImage(from: blend.imageData))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectedBlend = blend
                                }
                            Divider()
                            Text(blend.name)
                        }
                    }
                }
                .onDelete { offsets in
                    Task { await viewModel.delete(at: offsets) }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { Task { await viewModel.addBlend() } }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a blend")
        }
        .sheet(item: $viewModel.selectedBlend) { blend in
            BlendView(
                blend: blend,
                blendsRepository: blendsRepository,
                textRecognitionService: textRecognitionService
            ) { newBlend in
                viewModel.selectedBlend = newBlend
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

