//
//  ContentView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var selectedItem: Item?
    @State private var showImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        RecipeView(item: item)
                    } label: {
                        HStack {
                            Image(uiImage: avatarUIImage(from: item.imageData))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                    showImagePicker = true
                                }
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
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let item = selectedItem, let newPhoto else { return }
            Task {
                if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        item.imageData = data
                    }
                }
                // Clean up
                selectedPhoto = nil
                selectedItem = nil
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

