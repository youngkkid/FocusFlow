import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published private(set) var sessions: [FocusSession] = []

    private let habitsFile = "habits.v1.json"
    private let sessionsFile = "sessions.v1.json"

    init() {
        load()
        if habits.isEmpty {
            habits = [
                Habit(title: "Deep Work", symbolName: "brain.head.profile", colorHex: "#5B8CFF"),
                Habit(title: "Reading", symbolName: "book", colorHex: "#22C55E"),
                Habit(title: "Workout", symbolName: "figure.run", colorHex: "#F97316"),
            ]
            persist()
        }
    }

    func load() {
        habits = JSONFileStore.load([Habit].self, from: habitsFile) ?? []
        sessions = JSONFileStore.load([FocusSession].self, from: sessionsFile) ?? []
    }

    func persist() {
        JSONFileStore.save(habits, to: habitsFile)
        JSONFileStore.save(sessions, to: sessionsFile)
    }

    // MARK: Habits
    func upsertHabit(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx] = habit
        } else {
            habits.insert(habit, at: 0)
        }
        persist()
    }

    func deleteHabit(_ habitId: UUID) {
        habits.removeAll { $0.id == habitId }
        persist()
    }

    // MARK: Sessions
    func addSession(_ session: FocusSession) {
        sessions.insert(session, at: 0)
        persist()
    }
}

