//
//  BlendsView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI
import SwiftData

struct BlendsView: View {
    @Environment(\.dismiss) private var dismiss
    let onDismiss: ((CoffeeBlend) -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var blends: [CoffeeBlend]
    @State private var selectedBlend: CoffeeBlend?
    @State private var showBlendDetail = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(blends) { blend in
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
                                    selectedBlend = blend
                                    showBlendDetail = true
                                }
                            Divider()
                            Text(blend.name)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a blend")
        }
        .sheet(item: $selectedBlend) { blend in
            BlendView(blend: blend) { newBlend in
                selectedBlend = newBlend
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
                let newItem = CoffeeBlend(name: "New Blend")
                modelContext.insert(newItem)
            }
        }

        private func deleteItems(offsets: IndexSet) {
            withAnimation {
                for index in offsets {
                    modelContext.delete(blends[index])
                }
            }
        }
}
