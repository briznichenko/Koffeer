//
//  RecipeView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct RecipeView: View {
    let item: Item
    @StateObject private var viewModel: RecipeViewModel

    init(item: Item) {
        self.item = item
        _viewModel = StateObject(wrappedValue: RecipeViewModel(item: item))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: avatarUIImage(from: item.coffeeBlend.imageData))
                    .resizable()
                    .clipped()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top)
                ForEach(item.steps.indices, id: \.self) { index in
                    switch index {
                    case 0:
                        CollapsibleView(title: "Step №\(index + 1): \(item.steps[index] / 60):\(item.steps[index] % 60) sec", isExpanded: $viewModel.isExpanded1) {
                            Text("Pour 50ml")
                            AsyncImage(url: URL(string: "https://cdn.shopify.com/s/files/1/0800/4858/7043/files/Brew_Guide_Hario_V60_Step_1.jpg?v=1738619601")) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 200, height: 200)
                        }
                    case 1:
                        CollapsibleView(title: "Step №\(index + 1): \(item.steps[index] / 60):\(item.steps[index] % 60) sec", isExpanded: $viewModel.isExpanded2) {
                            Text("Pour 100ml")
                            AsyncImage(url: URL(string: "https://thecoffeecalculator.com/_next/image?url=%2Fimages%2Fguides%2Fpour-over-v60.jpg&w=3840&q=65")) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 200, height: 200)
                        }
                    case 2:
                        CollapsibleView(title: "Step №\(index + 1): \(item.steps[index] / 60):\(item.steps[index] % 60) sec", isExpanded: $viewModel.isExpanded3) {
                            Text("Pour 150ml")
                            AsyncImage(url: URL(string: "https://unionroasted.com/cdn/shop/articles/v60-brew-tip-hero_8c4fc3fa-ba4d-491d-9386-ed586a536256_850x.png?v=1547659010")) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 200, height: 200)
                        }
                    default: Text("")
                    }
                    Divider()
                }
            }

            Text(viewModel.formattedTime())
                .font(.system(.largeTitle, design: .monospaced))
                .bold()
                .accessibilityLabel("Timer")
                .accessibilityValue(viewModel.formattedTime())

            Button(action: viewModel.toggleTimer) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(viewModel.isRunning ? Color.orange : Color.accentColor))
                    .shadow(radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel(viewModel.isRunning ? "Pause timer" : "Start timer")

            HStack {
                Button(role: .destructive, action: viewModel.stopAndReset) {
                    Label("Reset", systemImage: "stop.fill")
                }
                .disabled(!viewModel.isRunning && viewModel.elapsedSeconds == 0)
            }
        }
        .padding()
        .onDisappear {
            viewModel.invalidateTimer()
        }
    }
}

#Preview {
    let sample = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
    RecipeView(item: sample)
}

