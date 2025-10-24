//
//  RecipesView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI
import SwiftData

struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var selectedItem: Item?
    @State private var showBlendDetail = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        RecipeView(item: item)
                    } label: {
                        HStack {
                            Image(uiImage: avatarUIImage(from: item.coffeeBlend.imageData))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                    showBlendDetail = true
                                }
                            Divider()
                            Text(item.coffeeBlend.name)
                            Divider()
                            Text(item.type?.rawValue ?? "blank")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            // No alert needed for image tap now
        } detail: {
            Text("Select an item")
        }
        .sheet(item: $selectedItem) { item in
            BlendsView() { newBlend in
                item.coffeeBlend = newBlend
            }
        }
    }
    
    // MARK: - Helpers
    
    // Keep this helper here for the list row thumbnail usage
    private func avatarUIImage(from data: Data?) -> UIImage {
        if let data, let image = UIImage(data: data) {
            return image
        }
        let dynamicColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        return UIImage(color: dynamicColor) ?? UIImage()
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

