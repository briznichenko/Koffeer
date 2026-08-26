//
//  KoffeerApp.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI
import SwiftData

@main
struct KoffeerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            CoffeeBlend.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: %(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootDIView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// Root view that constructs repositories/services using the environment ModelContext
private struct RootDIView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let blendsRepo = SwiftDataBlendsRepository(context: modelContext)
        let itemsRepo = SwiftDataItemsRepository(context: modelContext)
        let textService = VisionTextRecognitionService()

        ContentView(
            blendsRepository: blendsRepo,
            itemsRepository: itemsRepo,
            textRecognitionService: textService
        )
    }
}

