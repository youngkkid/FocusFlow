import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var app: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var timer: TimerViewModel
    @State private var lastProgress: Double = 0
    @State private var shouldAnimateProgress: Bool = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    FFCard {
                        VStack(spacing: 14) {
                            Text(timer.phase.title)
                                .font(.headline)

                            ZStack {
                                Circle()
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 14)
                                Circle()
                                    .trim(from: 0, to: timer.progress)
                                    .stroke(FFColor.gradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .animation(shouldAnimateProgress ? .easeInOut(duration: 0.25) : nil, value: timer.progress)

                                VStack(spacing: 6) {
                                    Text(timer.timeText)
                                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                                        .monospacedDigit()
                                    Text(timer.isRunning ? "Running" : "Paused")
                                        .font(.subheadline)
                                        .foregroundStyle(FFColor.secondaryText)
                                }
                            }
                            .frame(maxWidth: 320)
                            .frame(height: 280)
                            .padding(.vertical, 8)

                            HStack(spacing: 12) {
                                Button {
                                    timer.toggle(app: app)
                                } label: {
                                    Label(timer.isRunning ? "Pause" : "Start", systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(FFPrimaryButtonStyle())

                                Button {
                                    timer.reset(app: app)
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.headline)
                                        .frame(width: 48, height: 48)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Defaults")
                                .font(.headline)
                            HStack {
                                statChip(
                                    title: "Focus",
                                    value: "\(app.settings.focusMinutes)m",
                                    systemImage: "timer",
                                    isSelected: timer.phase == .focus,
                                    isEnabled: !timer.isRunning
                                ) {
                                    timer.setPhaseManually(.focus, settings: app.settings)
                                }
                                statChip(
                                    title: "Break",
                                    value: "\(app.settings.shortBreakMinutes)m",
                                    systemImage: "cup.and.saucer",
                                    isSelected: timer.phase == .shortBreak,
                                    isEnabled: !timer.isRunning
                                ) {
                                    timer.setPhaseManually(.shortBreak, settings: app.settings)
                                }
                                statChip(
                                    title: "Long",
                                    value: "\(app.settings.longBreakMinutes)m",
                                    systemImage: "moon.zzz",
                                    isSelected: timer.phase == .longBreak,
                                    isEnabled: !timer.isRunning
                                ) {
                                    timer.setPhaseManually(.longBreak, settings: app.settings)
                                }
                            }
                        }
                    }

                    if timer.didJustFinishPhase {
                        FFCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Session complete", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                Text("Nice work. Your next phase is ready whenever you are.")
                                    .font(.subheadline)
                                    .foregroundStyle(FFColor.secondaryText)

                                Button {
                                    timer.finalizeIfNeeded(app: app)
                                } label: {
                                    Label("Save & Continue", systemImage: "arrow.right")
                                }
                                .buttonStyle(FFPrimaryButtonStyle())
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Timer")
            .onAppear {
                timer.restoreIfPossible(app: app)
                lastProgress = timer.progress
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background, .inactive:
                    timer.handleSceneDidEnterBackground()
                case .active:
                    timer.handleSceneDidBecomeActive(app: app)
                    timer.finalizeIfNeeded(app: app)
                @unknown default:
                    break
                }
            }
            .onChange(of: timer.progress) { newValue in
                // Avoid a "catch-up" animation when returning to the screen after some time.
                // Small changes animate; large jumps update instantly.
                let delta = abs(newValue - lastProgress)
                shouldAnimateProgress = (scenePhase == .active) && (delta <= 0.03)
                lastProgress = newValue
            }
            .onChange(of: app.settings) { newValue in
                // If the timer isn't running, reflect new defaults immediately.
                timer.applySettingsIfNeeded(newValue)
            }
        }
    }

    private func statChip(
        title: String,
        value: String,
        systemImage: String,
        isSelected: Bool,
        isEnabled: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: systemImage)
                    .font(.caption)
                    .foregroundStyle(isSelected ? AnyShapeStyle(Color.white.opacity(0.92)) : AnyShapeStyle(FFColor.secondaryText))
                Text(value)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(isSelected ? AnyShapeStyle(Color.white) : AnyShapeStyle(FFColor.primaryText))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(isSelected ? AnyShapeStyle(FFColor.gradient) : AnyShapeStyle(FFColor.tertiaryBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(isEnabled ? 1.0 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    let app = AppModel()
    TimerView(timer: app.timer)
        .environmentObject(app)
}

