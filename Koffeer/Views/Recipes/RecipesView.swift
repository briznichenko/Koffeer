//
//  RecipesView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel: RecipesViewModel

    private let blendsRepository: BlendsRepository
    private let textRecognitionService: TextRecognitionService
    private let brewClock: any BrewClock

    init(
        itemsRepository: ItemsRepository,
        blendsRepository: BlendsRepository,
        textRecognitionService: TextRecognitionService,
        brewClock: any BrewClock
    ) {
        _viewModel = StateObject(wrappedValue: RecipesViewModel(itemsRepository: itemsRepository))
        self.blendsRepository = blendsRepository
        self.textRecognitionService = textRecognitionService
        self.brewClock = brewClock
    }

    var body: some View {
        NavigationSplitView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading brews…")
                }
                if let message = viewModel.loadErrorMessage {
                    Text(message).foregroundStyle(.red)
                    Button("Retry") { Task { await viewModel.load() } }
                }
                if let message = viewModel.operationErrorMessage {
                    Text(message).foregroundStyle(.red)
                }
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        RecipeView(item: item, clock: brewClock)
                    } label: {
                        HStack {
                            Image(uiImage: avatarUIImage(from: item.coffeeBlend.imageData))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectedItem = item
                                }
                            Divider()
                            Text(item.coffeeBlend.name)
                            Divider()
                            Text(item.type?.rawValue ?? "blank")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { Task { await viewModel.addItem() } }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .disabled(viewModel.isMutating)
                }
            }
        } detail: {
            Text("Select an item")
        }
        .sheet(item: $viewModel.selectedItem) { item in
            BlendsView(
                blendsRepository: blendsRepository,
                textRecognitionService: textRecognitionService
            ) { newBlend in
                Task { await viewModel.assignBlend(newBlend, to: item) }
            }
            .disabled(viewModel.isMutating)
            .interactiveDismissDisabled(viewModel.isMutating)
            .safeAreaInset(edge: .bottom) {
                if let message = viewModel.operationErrorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.regularMaterial)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    Text("Preview not configured for DI")
}

