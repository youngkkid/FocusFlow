import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var app: AppModel
    @StateObject private var vm = HabitsViewModel()

    @State private var isPresentingNewHabit = false
    @State private var habitIdPendingDelete: UUID?
    @State private var isDeleteAlertPresented = false
    @State private var selectedHabitId: UUID?
    @State private var isShowingDetail = false

    var body: some View {
        NavigationView {
            Group {
                if vm.activeHabits(from: app.store.habits).isEmpty {
                    HabitsEmptyState(onAdd: { isPresentingNewHabit = true })
                        .padding(16)
                } else {
                    List {
                        Section {
                            ForEach(vm.activeHabits(from: app.store.habits)) { habit in
                                NavigationLink(destination: HabitDetailView(habitId: habit.id)) {
                                    HStack(spacing: 12) {
                                        Image(systemName: habit.symbolName)
                                            .frame(width: 28)
                                            .foregroundStyle(FFColor.brand)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(habit.title)
                                            Text("Tap to view details")
                                                .font(.caption)
                                                .foregroundStyle(FFColor.secondaryText)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete { indexSet in
                                let habits = vm.activeHabits(from: app.store.habits)
                                guard let idx = indexSet.first, idx < habits.count else { return }
                                habitIdPendingDelete = habits[idx].id
                                isDeleteAlertPresented = true
                            }
                        } header: {
                            Text("Active")
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add habit")
                }
            }
            .background(
                NavigationLink(
                    destination: Group {
                        if let id = selectedHabitId {
                            HabitDetailView(habitId: id)
                        }
                    },
                    isActive: $isShowingDetail
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .sheet(isPresented: $isPresentingNewHabit) {
                NewHabitView()
            }
            .onChange(of: app.pendingHabitIdToOpen) { newValue in
                guard let id = newValue else { return }
                selectedHabitId = id
                isShowingDetail = true
                app.pendingHabitIdToOpen = nil
            }
            .onAppear {
                // Handle the case when the deep-link value was set before this view was mounted.
                if let id = app.pendingHabitIdToOpen {
                    selectedHabitId = id
                    isShowingDetail = true
                    app.pendingHabitIdToOpen = nil
                }
            }
            .alert("Delete habit?", isPresented: $isDeleteAlertPresented) {
                Button("Cancel", role: .cancel) {
                    habitIdPendingDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let id = habitIdPendingDelete {
                        app.store.deleteHabit(id)
                    }
                    habitIdPendingDelete = nil
                }
            } message: {
                Text("This will remove the habit from your list. Your past sessions remain in Stats.")
            }
        }
    }
}

private struct HabitsEmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FFCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("No habits yet", systemImage: "checklist")
                        .font(.headline)
                    Text("Create a habit to group your focus sessions and keep things intentional.")
                        .font(.subheadline)
                        .foregroundStyle(FFColor.secondaryText)

                    Button(action: onAdd) {
                        Label("Add habit", systemImage: "plus")
                    }
                    .buttonStyle(FFPrimaryButtonStyle())
                }
            }
        }
    }
}

#Preview {
    HabitsView()
        .environmentObject(AppModel())
}

