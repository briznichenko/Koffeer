//
//  RecipeView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct RecipeView: View {
    let item: Item

    @State private var isRunning = false
    @State private var elapsedSeconds: Double = 0
    @State private var timer: Timer?
    // Track next stop time in seconds
    @State private var currentStopSec: Int?
    
    @State private var isExpanded1: Bool?
    @State private var isExpanded2: Bool?
    @State private var isExpanded3: Bool?

    var body: some View {
        VStack(spacing: 16) {
            Image(uiImage: avatarUIImage(from: item.imageData))
                .resizable()
                .clipped()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top)
            ForEach(item.steps.indices, id: \.self) { index in
                CollapsibleView(title: "Step №\(index + 1): \(item.steps[index] / 60):\(item.steps[index] % 60) sec") {
                    switch index {
                    case 0:
                        Text("Pour 50ml")
                        AsyncImage(url: URL(string: "https://cdn.shopify.com/s/files/1/0800/4858/7043/files/Brew_Guide_Hario_V60_Step_1.jpg?v=1738619601")) { result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 200, height: 200)
                    case 1:
                        Text("Pour 100ml")
                        AsyncImage(url: URL(string: "https://thecoffeecalculator.com/_next/image?url=%2Fimages%2Fguides%2Fpour-over-v60.jpg&w=3840&q=65")) { result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 200, height: 200)
                    case 2:
                        Text("Pour 150ml")
                        AsyncImage(url: URL(string: "https://unionroasted.com/cdn/shop/articles/v60-brew-tip-hero_8c4fc3fa-ba4d-491d-9386-ed586a536256_850x.png?v=1547659010")) { result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 200, height: 200)
                    default: Text("")
                    }
                }
                Divider()
            }

            Text(formattedTime(elapsedSeconds))
                .font(.system(.largeTitle, design: .monospaced))
                .bold()
                .accessibilityLabel("Timer")
                .accessibilityValue(formattedTime(elapsedSeconds))

            // Start/Resume toggle button (round)
            Button(action: toggleTimer) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(isRunning ? Color.orange : Color.accentColor))
                    .shadow(radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel(isRunning ? "Pause timer" : "Start timer")

            // Explicit Pause and Reset controls
            HStack {
                Button("Pause", action: pauseTimer)
                    .disabled(!isRunning)

                Button(role: .destructive, action: stopAndReset) {
                    Label("Reset", systemImage: "stop.fill")
                }
                .disabled(!isRunning && elapsedSeconds == 0)
            }
        }
        .padding()
        .onDisappear {
            invalidateTimer()
        }
    }

    // MARK: - Timer logic

    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        invalidateTimer()

        // Determine current/next stop threshold in seconds
        if let currentStopSec, Double(currentStopSec) >= elapsedSeconds {
            if let nextStepSec = item.steps.first(where: { $0 > currentStopSec }) {
                self.currentStopSec = nextStepSec
            }
        } else if let firstStepSec = item.steps.first {
            currentStopSec = firstStepSec
        } else {
            currentStopSec = nil
        }

        isRunning = true

        // Tick every 10 ms for millisecond display
        let interval: TimeInterval = 0.01
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            elapsedSeconds += interval

            if let stopSec = currentStopSec, elapsedSeconds >= Double(stopSec) {
                pauseTimer()
            }
        }
        if let timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func pauseTimer() {
        invalidateTimer()
        isRunning = false
    }
    
    private func stopAndReset() {
        invalidateTimer()
        elapsedSeconds = 0
        isRunning = false
        currentStopSec = item.steps.first
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Format as mm:ss.SSS (milliseconds)
    private func formattedTime(_ elapsedSeconds: Double) -> String {
        let totalMilliseconds = Int((elapsedSeconds * 1000).rounded(.down))
        let minutes = (totalMilliseconds / 1000) / 60
        let seconds = (totalMilliseconds / 1000) % 60
        let milliseconds = totalMilliseconds % 100
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// MARK: - Helpers (scoped to this file)
private func avatarUIImage(from data: Data?) -> UIImage {
    if let data, let image = UIImage(data: data) {
        return image
    }
    let dynamicColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    return UIImage(color: dynamicColor) ?? UIImage()
}

#Preview {
    // Preview with a sample item
    let sample = Item(timestamp: Date(), type: .v60, steps: [30, 90, 180])
    RecipeView(item: sample)
}
