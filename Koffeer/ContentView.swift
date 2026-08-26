//
//  ContentView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI

struct ContentView: View {
    let blendsRepository: BlendsRepository
    let itemsRepository: ItemsRepository
    let textRecognitionService: TextRecognitionService

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView(itemsRepository: itemsRepository, blendsRepository: blendsRepository, textRecognitionService: textRecognitionService)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(1)

            BlendsView(blendsRepository: blendsRepository, textRecognitionService: textRecognitionService, onDismiss: .none)
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Blends")
                }
                .tag(2)
        }
    }
}

