//
//  RecipeView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.scenePhase) private var scenePhase

    let item: Item
    @State private var viewModel: RecipeViewModel

    init(item: Item, clock: any BrewClock) {
        self.item = item
        _viewModel = State(initialValue: RecipeViewModel(item: item, clock: clock))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: avatarUIImage(from: item.coffeeBlend.imageData))
                    .resizable()
                    .clipped()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top)
                ForEach(item.steps.indices, id: \.self) { index in
                    CollapsibleView(
                        title: "Step №\(index + 1): \(item.steps[index] / 60):\(String(format: "%02d", item.steps[index] % 60))",
                        isExpanded: Binding(
                            get: { viewModel.expandedStepIndex == index },
                            set: { viewModel.expandedStepIndex = $0 ? index : nil }
                        )
                    ) {
                        Label(
                            viewModel.activeStepIndex == index ? "Current step" : "Brew step",
                            systemImage: "drop.fill"
                        )
                        Text("Continue brewing until the timer reaches this step’s time.")
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
            .disabled(!viewModel.isRunning && !viewModel.canStartTimer)

            HStack {
                Button(role: .destructive, action: viewModel.stopAndReset) {
                    Label("Reset", systemImage: "stop.fill")
                }
                .disabled(!viewModel.isRunning && viewModel.elapsedSeconds == 0)
            }
        }
        .padding()
        .onDisappear {
            viewModel.pauseTimer()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                viewModel.pauseTimer()
            }
        }
    }
}

#Preview {
    let sample = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
    RecipeView(item: sample, clock: ContinuousBrewClock())
}

