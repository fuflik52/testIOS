import SwiftUI

/// Sheet for creating a habit or editing its name, icon and color.
struct HabitEditor: View {
    enum Mode {
        case create
        case edit(Habit)
    }

    @EnvironmentObject private var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var title: String
    @State private var emoji: String
    @State private var colorIndex: Int
    @FocusState private var isTitleFocused: Bool

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _emoji = State(initialValue: "💧")
            _colorIndex = State(initialValue: 1)
        case .edit(let habit):
            _title = State(initialValue: habit.title)
            _emoji = State(initialValue: habit.emoji)
            _colorIndex = State(initialValue: habit.colorIndex)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var color: Color { Palette.color(colorIndex) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    preview
                    nameField
                    if !isEditing { ideas }
                    emojiPicker
                    colorPicker
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Изменить" : "Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { save() }
                        .fontWeight(.semibold)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            if !isEditing { isTitleFocused = true }
        }
    }

    private var preview: some View {
        HStack(spacing: 14) {
            EmojiBadge(emoji: emoji, color: color, size: 56)
            VStack(alignment: .leading, spacing: 3) {
                Text(trimmedTitle.isEmpty ? "Название привычки" : trimmedTitle)
                    .font(.headline)
                    .foregroundStyle(trimmedTitle.isEmpty ? Color.secondary : Color.primary)
                    .lineLimit(2)
                Text("Каждый день")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .card()
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Название")
            TextField("Например, стакан воды утром", text: $title)
                .focused($isTitleFocused)
                .submitLabel(.done)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
    }

    private var ideas: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Идеи")
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(Palette.ideas, id: \.title) { idea in
                        Button {
                            withAnimation(.snappy) {
                                title = idea.title
                                emoji = idea.emoji
                            }
                        } label: {
                            Text(idea.emoji + " " + idea.title)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -20)
        }
    }

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Иконка")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Palette.emojis, id: \.self) { item in
                    let isSelected = item == emoji
                    Button {
                        withAnimation(.snappy(duration: 0.2)) { emoji = item }
                    } label: {
                        Text(item)
                            .font(.system(size: 26))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? color.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: emoji)
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Цвет")
            HStack(spacing: 0) {
                ForEach(Palette.colors.indices, id: \.self) { index in
                    let isSelected = index == colorIndex
                    Button {
                        withAnimation(.snappy(duration: 0.2)) { colorIndex = index }
                    } label: {
                        Circle()
                            .fill(Palette.colors[index])
                            .frame(width: 28, height: 28)
                            .padding(4)
                            .overlay {
                                Circle()
                                    .strokeBorder(Palette.colors[index], lineWidth: 2)
                                    .opacity(isSelected ? 1 : 0)
                            }
                            .scaleEffect(isSelected ? 1 : 0.9)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Цвет \(index + 1)")
                }
            }
            .padding(.vertical, 12)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .sensoryFeedback(.selection, trigger: colorIndex)
    }

    private func save() {
        guard !trimmedTitle.isEmpty else { return }
        switch mode {
        case .create:
            withAnimation(.snappy) {
                store.add(title: trimmedTitle, emoji: emoji, colorIndex: colorIndex)
            }
        case .edit(let habit):
            store.update(habit.id) {
                $0.title = trimmedTitle
                $0.emoji = emoji
                $0.colorIndex = colorIndex
            }
        }
        dismiss()
    }
}
