//
//  ContentView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(1)

            BlendsView(onDismiss: .none)
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Blends")
                }
                .tag(2)
        }
    }
}
