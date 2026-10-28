import Foundation

@MainActor
protocol BrewClock {
    var now: TimeInterval { get }
    func sleepUntilNextRefresh() async throws
}

@MainActor
final class ContinuousBrewClock: BrewClock {
    private let clock = ContinuousClock()
    private let origin = ContinuousClock.now

    var now: TimeInterval {
        let duration = origin.duration(to: clock.now).components
        return Double(duration.seconds) + Double(duration.attoseconds) / 1e18
    }

    func sleepUntilNextRefresh() async throws {
        try await clock.sleep(for: .milliseconds(50))
    }
}
