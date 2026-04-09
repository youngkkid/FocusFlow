import Foundation
import Combine

@MainActor
final class HabitsViewModel: ObservableObject {
    func activeHabits(from habits: [Habit]) -> [Habit] {
        habits
            .sorted { $0.createdAt > $1.createdAt }
    }
}

