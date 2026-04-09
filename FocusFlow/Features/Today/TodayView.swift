import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var app: AppModel
    @StateObject private var vm = TodayViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(app.timer.isRunning ? "In progress" : "Quick start")
                                .font(.headline)
                            Text(app.timer.isRunning ? "Your timer is running. Jump back in to stay on track." : "Jump into a focus session with your default settings.")
                                .font(.subheadline)
                                .foregroundStyle(FFColor.secondaryText)

                            Button {
                                vm.startQuickFocus(app: app)
                            } label: {
                                Label(app.timer.isRunning ? "Open Timer" : "Start Focus", systemImage: app.timer.isRunning ? "arrow.right" : "play.fill")
                            }
                            .buttonStyle(FFPrimaryButtonStyle())
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Habits")
                                .font(.headline)
                            if app.store.habits.isEmpty {
                                Text("Create a habit to track focus by context.")
                                    .foregroundStyle(FFColor.secondaryText)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(app.store.habits.prefix(3)) { habit in
                                        Button {
                                            app.pendingHabitIdToOpen = habit.id
                                            app.selectedTab = .habits
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: habit.symbolName)
                                                    .frame(width: 28)
                                                    .foregroundStyle(FFColor.brand)
                                                Text(habit.title)
                                                    .foregroundStyle(FFColor.primaryText)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.footnote)
                                                    .foregroundStyle(FFColor.secondaryText)
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today")
                                .font(.headline)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(vm.todayFocusMinutes(from: app.store.sessions)) min")
                                        .font(.system(.title3, design: .rounded).weight(.semibold))
                                    Text("Focused")
                                        .font(.subheadline)
                                        .foregroundStyle(FFColor.secondaryText)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(vm.todaySessionsCount(from: app.store.sessions))")
                                        .font(.system(.title3, design: .rounded).weight(.semibold))
                                    Text("Sessions")
                                        .font(.subheadline)
                                        .foregroundStyle(FFColor.secondaryText)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Today")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.greeting)
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
            Text("Build momentum with small wins.")
                .foregroundStyle(FFColor.secondaryText)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    TodayView()
        .environmentObject(AppModel())
}

