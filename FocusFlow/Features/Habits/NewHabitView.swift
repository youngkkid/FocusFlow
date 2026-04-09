import SwiftUI

struct NewHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var app: AppModel
    @StateObject private var vm = NewHabitViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section("Basics") {
                    TextField("Title", text: $vm.title)
                        .textInputAutocapitalization(.words)
                }

                Section("Icon") {
                    SymbolPickerGrid(
                        symbols: vm.availableSymbols,
                        selection: $vm.symbolName
                    )
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.save(into: app.store)
                        dismiss()
                    }
                    .disabled(vm.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NewHabitView()
        .environmentObject(AppModel())
}

private struct SymbolPickerGrid: View {
    let symbols: [String]
    @Binding var selection: String

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 44), spacing: 10),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(symbols, id: \.self) { name in
                Button {
                    selection = name
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selection == name ? AnyShapeStyle(FFColor.gradient) : AnyShapeStyle(FFColor.tertiaryBackground))
                            .frame(height: 44)

                        Image(systemName: name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selection == name ? AnyShapeStyle(Color.white) : AnyShapeStyle(FFColor.primaryText))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(name)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

