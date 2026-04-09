import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject private var app: AppModel
    @Environment(\.dismiss) private var dismiss
    let habitId: UUID
    @State private var isDeleteAlertPresented = false

    private var habit: Habit? {
        app.store.habits.first(where: { $0.id == habitId })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let habit {
                    FFCard {
                        HStack(spacing: 12) {
                            Image(systemName: habit.symbolName)
                                .font(.system(size: 22, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .background(FFColor.tertiaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.title)
                                    .font(.title3.weight(.semibold))
                                Text(habit.isArchived ? "Archived" : "Active")
                                    .font(.subheadline)
                                    .foregroundStyle(FFColor.secondaryText)
                            }
                            Spacer()
                        }
                    }

                    FFCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Actions")
                                .font(.headline)
                            Button {
                                isDeleteAlertPresented = true
                            } label: {
                                Label("Delete habit", systemImage: "trash")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                } else {
                    FFCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Habit not found", systemImage: "questionmark.folder")
                                .font(.headline)
                            Text("It may have been deleted or is unavailable.")
                                .font(.subheadline)
                                .foregroundStyle(FFColor.secondaryText)
                        }
                    }
                    .padding(.top, 40)
                }
            }
            .padding(16)
        }
        .navigationTitle("Habit")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete habit?", isPresented: $isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                app.store.deleteHabit(habitId)
                dismiss()
            }
        } message: {
            Text("This will remove the habit from your list. Your past sessions remain in Stats.")
        }
    }
}

#Preview {
    NavigationView {
        HabitDetailView(habitId: UUID())
            .environmentObject(AppModel())
    }
}

