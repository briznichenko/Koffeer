//
//  RecipesView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel: RecipesViewModel

    let itemsRepository: ItemsRepository
    let blendsRepository: BlendsRepository
    let textRecognitionService: TextRecognitionService

    init(itemsRepository: ItemsRepository, blendsRepository: BlendsRepository, textRecognitionService: TextRecognitionService) {
        _viewModel = StateObject(wrappedValue: RecipesViewModel(itemsRepository: itemsRepository))
        self.itemsRepository = itemsRepository
        self.blendsRepository = blendsRepository
        self.textRecognitionService = textRecognitionService
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        RecipeView(item: item)
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { Task { await viewModel.addItem() } }) {
                        Label("Add Item", systemImage: "plus")
                    }
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
                // Update selected item's blend reference
                item.coffeeBlend = newBlend
                Task { await viewModel.load() }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    // Previews could be wired with mock repos/services if needed.
    Text("Preview not configured for DI")
}

