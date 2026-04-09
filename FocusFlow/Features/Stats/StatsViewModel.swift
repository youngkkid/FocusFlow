import Foundation
import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    var weekStartDate: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: -6, to: today) ?? today
    }

    func weekSessions(from sessions: [FocusSession]) -> Int {
        weekSessionsAllKinds(from: sessions).count
    }

    func weekTotalMinutes(from sessions: [FocusSession]) -> Int {
        let seconds = weekSessionsAllKinds(from: sessions).reduce(0) { $0 + $1.actualSeconds }
        return Int(round(Double(seconds) / 60.0))
    }

    func weeklyBars(from sessions: [FocusSession]) -> [Int] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = weekStartDate

        var minutesByDay: [Date: Int] = [:]
        for i in 0..<7 {
            if let d = cal.date(byAdding: .day, value: i, to: start) {
                minutesByDay[cal.startOfDay(for: d)] = 0
            }
        }

        for s in sessions {
            let d = cal.startOfDay(for: s.startedAt)
            guard d >= start && d <= today else { continue }
            minutesByDay[d, default: 0] += Int(round(Double(s.actualSeconds) / 60.0))
        }

        return (0..<7).compactMap { i in
            guard let d = cal.date(byAdding: .day, value: i, to: start) else { return nil }
            return minutesByDay[cal.startOfDay(for: d)] ?? 0
        }
    }

    func allTimeSessions(from sessions: [FocusSession]) -> Int {
        sessions.count
    }

    func allTimeTotalHours(from sessions: [FocusSession]) -> Int {
        let seconds = sessions.reduce(0) { $0 + $1.actualSeconds }
        return Int(round(Double(seconds) / 3600.0))
    }

    private func weekSessionsAllKinds(from sessions: [FocusSession]) -> [FocusSession] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -6, to: today) ?? today
        return sessions.filter { $0.startedAt >= start }
    }
}

