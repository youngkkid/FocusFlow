import Foundation
import SwiftUI
import Combine

@MainActor
final class AppModel: ObservableObject {
    enum Tab: Hashable {
        case today
        case timer
        case habits
        case stats
        case settings
    }

    @Published var settings: AppSettings
    @Published var store: AppStore
    @Published var selectedTab: Tab = .today
    @Published var pendingHabitIdToOpen: UUID?

    let timer: TimerViewModel
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.settings = AppSettings.load()
        self.store = AppStore()
        self.timer = TimerViewModel()

        // Forward nested store changes so SwiftUI updates screens that read `app.store.*`.
        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

