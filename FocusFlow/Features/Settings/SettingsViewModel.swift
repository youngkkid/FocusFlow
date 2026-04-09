import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    func resetDemoData(app: AppModel) {
        app.store = AppStore()
    }
}

