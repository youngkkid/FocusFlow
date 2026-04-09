import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Welcome back"
        }
    }

    func todaySessionsCount(from sessions: [FocusSession]) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return sessions.filter { $0.kind == .focus && $0.startedAt >= startOfDay }.count
    }

    func todayFocusMinutes(from sessions: [FocusSession]) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let seconds = sessions
            .filter { $0.kind == .focus && $0.startedAt >= startOfDay }
            .reduce(0) { $0 + $1.actualSeconds }
        return Int(round(Double(seconds) / 60.0))
    }

    func startQuickFocus(app: AppModel) {
        app.selectedTab = .timer
        if app.timer.isRunning {
            return
        }
        app.timer.startFocus(app: app)
    }
}

