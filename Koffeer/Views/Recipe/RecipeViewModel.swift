import Foundation
import Observation

@Observable
@MainActor
final class RecipeViewModel {
    let item: Item
    private let clock: any BrewClock
    @ObservationIgnored private var timerTask: Task<Void, Never>?
    @ObservationIgnored private var segmentStart: TimeInterval?
    @ObservationIgnored private var accumulatedSeconds: TimeInterval = 0

    private(set) var isRunning = false
    private(set) var elapsedSeconds: TimeInterval = 0
    private(set) var activeStepIndex: Int?
    var expandedStepIndex: Int?

    var canStartTimer: Bool {
        item.steps.contains { Double($0) > elapsedSeconds }
    }

    init(item: Item, clock: any BrewClock) {
        self.item = item
        self.clock = clock
        activeStepIndex = item.steps.firstIndex { $0 > 0 }
        expandedStepIndex = activeStepIndex
    }

    deinit {
        timerTask?.cancel()
    }

    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        guard !isRunning,
              let nextIndex = item.steps.firstIndex(where: { Double($0) > elapsedSeconds }) else { return }
        activeStepIndex = nextIndex
        expandedStepIndex = nextIndex
        accumulatedSeconds = elapsedSeconds
        segmentStart = clock.now
        isRunning = true
        let clock = clock
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await clock.sleepUntilNextRefresh()
                } catch {
                    break
                }
                guard !Task.isCancelled else { break }
                guard self != nil else { break }
                self?.refreshElapsedTime()
            }
        }
    }

    func refreshElapsedTime() {
        guard isRunning, let segmentStart, let activeStepIndex else { return }
        let elapsed = accumulatedSeconds + max(0, clock.now - segmentStart)
        let boundary = Double(item.steps[activeStepIndex])
        elapsedSeconds = min(elapsed, boundary)
        if elapsed >= boundary {
            endRun()
        }
    }

    func pauseTimer() {
        refreshElapsedTime()
        endRun()
    }

    func stopAndReset() {
        endRun()
        elapsedSeconds = 0
        accumulatedSeconds = 0
        activeStepIndex = item.steps.firstIndex { $0 > 0 }
        expandedStepIndex = activeStepIndex
    }

    private func endRun() {
        timerTask?.cancel()
        timerTask = nil
        accumulatedSeconds = elapsedSeconds
        segmentStart = nil
        isRunning = false
    }

    func formattedTime() -> String {
        let centiseconds = Int((elapsedSeconds * 100).rounded(.down))
        return String(format: "%02d:%02d.%02d", centiseconds / 6000, (centiseconds / 100) % 60, centiseconds % 100)
    }
}
