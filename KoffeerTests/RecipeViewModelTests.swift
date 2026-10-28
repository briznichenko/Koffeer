import Foundation
import Testing
@testable import Koffeer

@MainActor
private final class ManualBrewClock: BrewClock {
    var now: TimeInterval = 0

    func sleepUntilNextRefresh() async throws {
        try await Task.sleep(for: .seconds(3600))
    }
}

@MainActor
struct RecipeViewModelTests {
    @Test
    func manualPauseAndResumeKeepTheSameStepAndExcludePausedTime() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [30, 90]), clock: clock)
        viewModel.startTimer()
        clock.now = 12
        viewModel.pauseTimer()
        #expect(viewModel.elapsedSeconds == 12)
        clock.now = 100

        viewModel.startTimer()
        #expect(viewModel.activeStepIndex == 0)
        clock.now = 105
        viewModel.pauseTimer()

        #expect(viewModel.elapsedSeconds == 17)
        #expect(!viewModel.isRunning)
    }

    @Test
    func delayedRefreshStopsExactlyAtBoundaryAndResumeSelectsNextStep() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [30, 90]), clock: clock)
        viewModel.startTimer()
        clock.now = 45

        viewModel.refreshElapsedTime()

        #expect(viewModel.elapsedSeconds == 30)
        #expect(!viewModel.isRunning)
        viewModel.startTimer()
        #expect(viewModel.activeStepIndex == 1)
        clock.now = 105
        viewModel.refreshElapsedTime()
        #expect(viewModel.elapsedSeconds == 90)
        #expect(!viewModel.isRunning)
        #expect(!viewModel.canStartTimer)
        viewModel.startTimer()
        #expect(!viewModel.isRunning)
    }

    @Test
    func resetRestoresFirstStepAndAllowsRestart() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [30, 90]), clock: clock)
        viewModel.startTimer()
        clock.now = 40
        viewModel.refreshElapsedTime()
        viewModel.startTimer()

        viewModel.stopAndReset()

        #expect(viewModel.elapsedSeconds == 0)
        #expect(viewModel.activeStepIndex == 0)
        #expect(viewModel.expandedStepIndex == 0)
        #expect(!viewModel.isRunning)
        #expect(viewModel.canStartTimer)
    }

    @Test
    func emptyStepsCannotStart() {
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: []), clock: ManualBrewClock())

        viewModel.startTimer()
        viewModel.stopAndReset()

        #expect(!viewModel.isRunning)
        #expect(!viewModel.canStartTimer)
        #expect(viewModel.activeStepIndex == nil)
    }

    @Test
    func arbitraryStepsAndDuplicateBoundariesDoNotTrapTimer() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [0, 10, 10, 20, 40]), clock: clock)
        for expectedIndex in [1, 3, 4] {
            viewModel.startTimer()
            #expect(viewModel.activeStepIndex == expectedIndex)
            clock.now += 100
            viewModel.refreshElapsedTime()
            #expect(!viewModel.isRunning)
        }
        #expect(viewModel.elapsedSeconds == 40)
        #expect(!viewModel.canStartTimer)
    }

    @Test
    func screenExitAndReentryExcludeTimeAway() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [30]), clock: clock)
        viewModel.startTimer()
        clock.now = 5
        viewModel.pauseTimer()
        clock.now = 1000
        viewModel.refreshElapsedTime()
        #expect(viewModel.elapsedSeconds == 5)

        viewModel.startTimer()
        clock.now = 1005
        viewModel.pauseTimer()
        #expect(viewModel.elapsedSeconds == 10)
    }

    @Test
    func timeUsesCentiseconds() {
        let clock = ManualBrewClock()
        let viewModel = RecipeViewModel(item: Item(timestamp: .now, type: .v60, steps: [180]), clock: clock)
        viewModel.startTimer()
        clock.now = 65.129
        viewModel.pauseTimer()

        #expect(viewModel.formattedTime() == "01:05.12")
    }
}
