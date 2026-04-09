import Foundation
import Combine

@MainActor
final class NewHabitViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var symbolName: String = "sparkles"

    let availableSymbols: [String] = [
        "sparkles",
        "timer",
        "brain.head.profile",
        "book",
        "pencil.and.outline",
        "laptopcomputer",
        "music.note",
        "leaf",
        "figure.walk",
        "figure.run",
        "dumbbell",
        "heart",
        "sun.max",
        "moon.zzz",
        "cup.and.saucer",
        "drop",
        "bolt",
        "flame",
        "checkmark.circle",
        "target",
        "chart.xyaxis.line",
        "calendar",
        "bell",
        "paintpalette",
        "camera",
        "square.and.pencil",
        "lightbulb",
        "folder",
        "paperplane",
        "globe",
    ]

    func save(into store: AppStore) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.upsertHabit(Habit(title: trimmed, symbolName: symbolName))
    }
}

