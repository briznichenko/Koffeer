import Foundation
import SwiftUI
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {
    let item: Item

    // Timer state
    @Published var isRunning = false
    @Published var elapsedSeconds: Double = 0
    private var timer: Timer?

    @Published var currentStopSec: Int? {
        didSet {
            switch currentStopSec {
            case 30:
                isExpanded1 = true; isExpanded2 = false; isExpanded3 = false
            case 90:
                isExpanded1 = false; isExpanded2 = true; isExpanded3 = false
            case 180:
                isExpanded1 = false; isExpanded2 = false; isExpanded3 = true
            default:
                isExpanded1 = false; isExpanded2 = false; isExpanded3 = false
            }
        }
    }

    @Published var isExpanded1 = false
    @Published var isExpanded2 = false
    @Published var isExpanded3 = false

    init(item: Item) {
        self.item = item
    }

    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        invalidateTimer()

        if let currentStopSec, currentStopSec >= Int(elapsedSeconds) {
            if let nextStepSec = item.steps.first(where: { $0 > currentStopSec }) {
                self.currentStopSec = nextStepSec
            }
        } else if let firstStepSec = item.steps.first {
            currentStopSec = firstStepSec
        } else {
            currentStopSec = nil
        }

        isRunning = true

        let interval: TimeInterval = 0.01
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += interval

            if let stopSec = self.currentStopSec, self.elapsedSeconds >= Double(stopSec) {
                self.pauseTimer()
            }
        }
        if let timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    func pauseTimer() {
        invalidateTimer()
        isRunning = false
    }

    func stopAndReset() {
        invalidateTimer()
        elapsedSeconds = 0
        isRunning = false
        currentStopSec = item.steps.first
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formattedTime() -> String {
        let totalMilliseconds = Int((elapsedSeconds * 1000).rounded(.down))
        let minutes = (totalMilliseconds / 1000) / 60
        let seconds = (totalMilliseconds / 1000) % 60
        let milliseconds = totalMilliseconds % 100
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

