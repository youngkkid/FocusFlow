import Foundation

struct FocusSession: Identifiable, Codable, Equatable {
    enum Kind: String, Codable, CaseIterable, Identifiable {
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

    var id: UUID
    var startedAt: Date
    var endedAt: Date
    var plannedSeconds: Int
    var kind: Kind
    var habitId: UUID?

    var actualSeconds: Int {
        max(0, Int(endedAt.timeIntervalSince(startedAt)))
    }

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        plannedSeconds: Int,
        kind: Kind,
        habitId: UUID?
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedSeconds = plannedSeconds
        self.kind = kind
        self.habitId = habitId
    }
}

