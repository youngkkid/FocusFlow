import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        TabView(selection: $app.selectedTab) {
            TodayView()
                .tag(AppModel.Tab.today)
                .tabItem { Label("Today", systemImage: "sparkles") }

            TimerView(timer: app.timer)
                .tag(AppModel.Tab.timer)
                .tabItem { Label("Timer", systemImage: "timer") }

            HabitsView()
                .tag(AppModel.Tab.habits)
                .tabItem { Label("Habits", systemImage: "checklist") }

            StatsView()
                .tag(AppModel.Tab.stats)
                .tabItem { Label("Stats", systemImage: "chart.xyaxis.line") }

            SettingsView()
                .tag(AppModel.Tab.settings)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppModel())
}

