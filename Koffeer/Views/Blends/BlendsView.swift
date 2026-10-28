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

    private let blendsRepository: BlendsRepository
    private let textRecognitionService: TextRecognitionService
    private let onDismiss: ((CoffeeBlend) -> Void)?

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
                if viewModel.isLoading {
                    ProgressView("Loading blends…")
                }
                if let message = viewModel.loadErrorMessage {
                    Text(message).foregroundStyle(.red)
                    Button("Retry") { Task { await viewModel.load() } }
                }
                if let message = viewModel.operationErrorMessage {
                    Text(message).foregroundStyle(.red)
                }
                ForEach(viewModel.blends) { blend in
                    NavigationLink {
                        Button("Done") {
                            if let onDismiss {
                                onDismiss(blend)
                            } else {
                                dismiss()
                            }
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
                .deleteDisabled(viewModel.isMutating)
            }
            .refreshable { await viewModel.load() }
            .toolbar {
                ToolbarItem {
                    Button(action: { Task { await viewModel.addBlend() } }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .disabled(viewModel.isMutating)
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

