import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppModel
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section("Timer") {
                    Stepper(value: $app.settings.focusMinutes, in: 5...90, step: 5) {
                        HStack {
                            Text("Focus")
                            Spacer()
                            Text("\(app.settings.focusMinutes) min")
                                .foregroundStyle(FFColor.secondaryText)
                        }
                    }
                    Stepper(value: $app.settings.shortBreakMinutes, in: 1...30, step: 1) {
                        HStack {
                            Text("Short break")
                            Spacer()
                            Text("\(app.settings.shortBreakMinutes) min")
                                .foregroundStyle(FFColor.secondaryText)
                        }
                    }
                    Stepper(value: $app.settings.longBreakMinutes, in: 5...60, step: 5) {
                        HStack {
                            Text("Long break")
                            Spacer()
                            Text("\(app.settings.longBreakMinutes) min")
                                .foregroundStyle(FFColor.secondaryText)
                        }
                    }
                    Stepper(value: $app.settings.sessionsUntilLongBreak, in: 2...8, step: 1) {
                        HStack {
                            Text("Long break every")
                            Spacer()
                            Text("\(app.settings.sessionsUntilLongBreak) sessions")
                                .foregroundStyle(FFColor.secondaryText)
                        }
                    }
                }

                Section("Experience") {
                    Picker("Theme", selection: $app.settings.theme) {
                        ForEach(AppSettings.Theme.allCases) { t in
                            Text(t.title).tag(t)
                        }
                    }
                    Toggle("Haptics", isOn: $app.settings.hapticsEnabled)
                    Toggle("Sound", isOn: $app.settings.soundEnabled)
                }

                Section("App") {
                    Button(role: .destructive) {
                        vm.resetDemoData(app: app)
                    } label: {
                        Text("Reset local data")
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: app.settings) { newValue in
                newValue.save()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppModel())
}

