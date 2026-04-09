import Foundation
import Combine
import UIKit

@MainActor
final class TimerViewModel: ObservableObject {
    enum Phase: String, CaseIterable, Identifiable, Codable {
        case focus
        case shortBreak
        case longBreak

        var id: String { rawValue }
        var title: String {
            switch self {
            case .focus: "Focus"
            case .shortBreak: "Break"
            case .longBreak: "Long Break"
            }
        }
    }

    @Published private(set) var phase: Phase = .focus
    @Published private(set) var remainingSeconds: Int = 25 * 60
    @Published private(set) var totalSeconds: Int = 25 * 60
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var didJustFinishPhase: Bool = false

    private var timer: Timer?
    private var startedAt: Date?
    private var endAt: Date?
    private var completedFocusCountInCycle: Int = 0

    private let stateKey = "FocusFlow.TimerState.v1"

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        let done = Double(totalSeconds - remainingSeconds)
        return min(1, max(0, done / Double(totalSeconds)))
    }

    var timeText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func applySettingsIfNeeded(_ settings: AppSettings) {
        guard !isRunning else { return }
        setPhase(phase, settings: settings)
    }

    func toggle(app: AppModel) {
        if isRunning {
            pauseAndPersist()
        } else {
            start(app: app)
        }
    }

    func reset(app: AppModel) {
        stopAndClearPersistedState()
        completedFocusCountInCycle = 0
        didJustFinishPhase = false
        setPhase(.focus, settings: app.settings)
    }

    func startFocus(app: AppModel) {
        // Ensure the next run starts from Focus with latest settings.
        pauseAndPersist()
        startedAt = nil
        endAt = nil
        didJustFinishPhase = false
        setPhase(.focus, settings: app.settings)
        start(app: app)
    }

    func setPhaseManually(_ newPhase: Phase, settings: AppSettings) {
        guard !isRunning else { return }
        didJustFinishPhase = false
        startedAt = nil
        endAt = nil
        setPhase(newPhase, settings: settings)
        persist()
    }

    func restoreIfPossible(app: AppModel) {
        guard let restored = PersistedTimerState.load(from: stateKey) else {
            setPhase(.focus, settings: app.settings)
            return
        }

        completedFocusCountInCycle = restored.completedFocusCountInCycle
        phase = restored.phase
        totalSeconds = restored.totalSeconds
        startedAt = restored.startedAt
        endAt = restored.endAt

        if restored.isRunning, let endAt {
            let remaining = max(0, Int(endAt.timeIntervalSinceNow.rounded(.down)))
            remainingSeconds = remaining
            if remaining == 0 {
                // The phase ended while app wasn't active.
                finishPhase(app: app, finishedAt: Date())
                pauseAndPersist()
            } else {
                isRunning = true
                startInternalTimer()
            }
        } else {
            isRunning = false
            remainingSeconds = restored.remainingSeconds
        }
    }

    func handleSceneDidEnterBackground() {
        // Persist current state when app goes inactive/background.
        persist()
    }

    func handleSceneDidBecomeActive(app: AppModel) {
        guard isRunning, let endAt else { return }
        let remaining = max(0, Int(endAt.timeIntervalSinceNow.rounded(.down)))
        remainingSeconds = remaining
        if remaining == 0 {
            finishPhase(app: app, finishedAt: Date())
            pauseAndPersist()
        }
    }

    private func start(app: AppModel) {
        guard !isRunning else { return }
        isRunning = true
        didJustFinishPhase = false

        let now = Date()
        if startedAt == nil {
            startedAt = now
        }
        if endAt == nil {
            endAt = now.addingTimeInterval(TimeInterval(remainingSeconds))
        }

        startInternalTimer()
        persist()
    }

    private func startInternalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func pauseAndPersist() {
        isRunning = false
        timer?.invalidate()
        timer = nil

        // Freeze remaining time by clearing the absolute end timestamp.
        if let endAt {
            let remaining = max(0, Int(endAt.timeIntervalSinceNow.rounded(.down)))
            remainingSeconds = remaining
        }
        endAt = nil

        persist()
    }

    private func tick() {
        guard isRunning else { return }
        guard let endAt else {
            pauseAndPersist()
            return
        }

        let remaining = max(0, Int(endAt.timeIntervalSinceNow.rounded(.down)))
        remainingSeconds = remaining

        if remaining > 0 { return }

        // Finished.
        isRunning = false
        timer?.invalidate()
        timer = nil
        didJustFinishPhase = true

        // If phase finished while app is active, record immediately.
        // If app is backgrounded, handleSceneDidBecomeActive will catch up.
        // We purposely don't auto-start next phase; user controls start.
        persist()
    }

    /// Call from view when it detects `remainingSeconds == 0` while active.
    func finalizeIfNeeded(app: AppModel) {
        guard remainingSeconds == 0 else { return }
        guard !isRunning else { return }
        // Ensure we only finalize once per phase finish.
        guard startedAt != nil else { return }
        guard didJustFinishPhase else { return }
        finishPhase(app: app, finishedAt: Date())
        didJustFinishPhase = false
        pauseAndPersist()
    }

    private func finishPhase(app: AppModel?, finishedAt: Date) {
        let started = startedAt ?? finishedAt
        let planned = totalSeconds

        if let app {
            let kind: FocusSession.Kind
            switch phase {
            case .focus: kind = .focus
            case .shortBreak: kind = .shortBreak
            case .longBreak: kind = .longBreak
            }

            app.store.addSession(
                FocusSession(
                    startedAt: started,
                    endedAt: finishedAt,
                    plannedSeconds: planned,
                    kind: kind,
                    habitId: nil
                )
            )

            if app.settings.hapticsEnabled {
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
            }

            // Advance phase for next run.
            advancePhase(settings: app.settings)
        } else {
            // If we can't record (e.g. tick called without app), still advance locally.
            advancePhase(settings: AppSettings.load())
        }
    }

    private func advancePhase(settings: AppSettings) {
        switch phase {
        case .focus:
            completedFocusCountInCycle += 1
            let needsLong = (completedFocusCountInCycle % max(1, settings.sessionsUntilLongBreak) == 0)
            setPhase(needsLong ? .longBreak : .shortBreak, settings: settings)
        case .shortBreak, .longBreak:
            setPhase(.focus, settings: settings)
            startedAt = nil
            endAt = nil
        }

        // Prepare for next run (paused by default).
        isRunning = false
        startedAt = nil
        endAt = nil
        persist()
    }

    private func setPhase(_ newPhase: Phase, settings: AppSettings) {
        phase = newPhase
        let seconds: Int
        switch newPhase {
        case .focus: seconds = settings.focusMinutes * 60
        case .shortBreak: seconds = settings.shortBreakMinutes * 60
        case .longBreak: seconds = settings.longBreakMinutes * 60
        }
        totalSeconds = max(60, seconds)
        remainingSeconds = totalSeconds
    }

    private func persist() {
        let state = PersistedTimerState(
            phase: phase,
            totalSeconds: totalSeconds,
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            startedAt: startedAt,
            endAt: endAt,
            completedFocusCountInCycle: completedFocusCountInCycle
        )
        state.save(to: stateKey)
    }

    private func stopAndClearPersistedState() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        startedAt = nil
        endAt = nil
        UserDefaults.standard.removeObject(forKey: stateKey)
    }
}

private struct PersistedTimerState: Codable {
    var phase: TimerViewModel.Phase
    var totalSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool
    var startedAt: Date?
    var endAt: Date?
    var completedFocusCountInCycle: Int

    static func load(from key: String) -> PersistedTimerState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PersistedTimerState.self, from: data)
    }

    func save(to key: String) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

