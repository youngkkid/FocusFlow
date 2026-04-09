import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var app: AppModel
    @StateObject private var vm = StatsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if app.store.sessions.isEmpty {
                        FFCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("No stats yet", systemImage: "chart.xyaxis.line")
                                    .font(.headline)
                                Text("Complete a session to start building your trend.")
                                    .font(.subheadline)
                                    .foregroundStyle(FFColor.secondaryText)
                            }
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("This week")
                                .font(.headline)
                            HStack {
                                stat(title: "Minutes", value: "\(vm.weekTotalMinutes(from: app.store.sessions)) min")
                                Spacer()
                                stat(title: "Sessions", value: "\(vm.weekSessions(from: app.store.sessions))")
                            }
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trend")
                                .font(.headline)
                            WeekBars(
                                startDate: vm.weekStartDate,
                                values: vm.weeklyBars(from: app.store.sessions)
                            )
                            .frame(height: 150)
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("All time")
                                .font(.headline)
                            HStack {
                                stat(title: "Hours", value: "\(vm.allTimeTotalHours(from: app.store.sessions)) h")
                                Spacer()
                                stat(title: "Sessions", value: "\(vm.allTimeSessions(from: app.store.sessions))")
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Stats")
        }
    }

    private func stat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(FFColor.secondaryText)
        }
    }
}

private struct WeekBars: View {
    let startDate: Date
    let values: [Int] // 7 values, minutes per day

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                let maxV = max(1, values.max() ?? 1)
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(values.enumerated()), id: \.offset) { idx, v in
                        Group {
                            if idx == values.count - 1 {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(FFColor.gradient)
                            } else {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.primary.opacity(0.12))
                            }
                        }
                        .frame(height: max(6, geo.size.height * CGFloat(Double(v) / Double(maxV))))
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("\(weekdayLabel(for: idx)) \(v) minutes")
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { idx, _ in
                    Text(weekdayLabel(for: idx))
                        .font(.caption2)
                        .foregroundStyle(FFColor.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func weekdayLabel(for idx: Int) -> String {
        let cal = Calendar.current
        guard let date = cal.date(byAdding: .day, value: idx, to: startDate) else { return "" }
        let weekday = cal.component(.weekday, from: date) // 1...7
        let symbols = cal.shortWeekdaySymbols // Sunday...Saturday (locale-aware)
        let sym = symbols[max(0, min(symbols.count - 1, weekday - 1))]
        // Keep it compact (e.g. "Mon")
        return sym
    }
}

#Preview {
    StatsView()
        .environmentObject(AppModel())
}

