import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var symbolName: String
    var colorHex: String
    var isArchived: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        symbolName: String = "sparkles",
        colorHex: String = "#5B8CFF",
        isArchived: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.colorHex = colorHex
        self.isArchived = isArchived
        self.createdAt = createdAt
    }
}

