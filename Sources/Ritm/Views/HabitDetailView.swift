import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject private var store: HabitStore

    let habitID: UUID
    let today: Date

    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var isDeleted = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            if let habit = store.habit(id: habitID) {
                content(for: habit)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Изменить") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            if let habit = store.habit(id: habitID) {
                HabitEditor(mode: .edit(habit))
            }
        }
        .onDisappear {
            // Delete after the pop animation so the screen doesn't blank out mid-transition.
            if isDeleted { withAnimation(.snappy) { store.delete(habitID) } }
        }
    }

    private func content(for habit: Habit) -> some View {
        let color = Palette.color(habit.colorIndex)
        let rate = habit.completionRate(lastDays: 30, today: today)

        return VStack(spacing: 20) {
            VStack(spacing: 12) {
                EmojiBadge(emoji: habit.emoji, color: color, size: 88)
                Text(habit.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("Отслеживается с \(habit.createdAt.formatted(.dateTime.day().month(.wide).locale(Day.locale)))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            HStack(spacing: 12) {
                StatTile(value: "\(habit.currentStreak(today: today))", caption: "серия", color: color)
                StatTile(value: "\(habit.bestStreak)", caption: "рекорд", color: color)
                StatTile(value: "\(Int((rate * 100).rounded()))%", caption: "за 30 дней", color: color)
            }

            HistoryGrid(habit: habit, today: today, color: color) { day in
                store.toggle(habit.id, on: day)
            }

            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Text("Удалить привычку")
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
            .confirmationDialog(
                "Удалить привычку?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    isDeleted = true
                    dismiss()
                }
            } message: {
                Text("Вся история отметок будет удалена.")
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

/// The last six weeks as a calendar; any past day can be toggled.
private struct HistoryGrid: View {
    let habit: Habit
    let today: Date
    let color: Color
    let onToggle: (Date) -> Void

    @State private var taps = 0

    private let weeks = 6
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var days: [Date] {
        let monday = Day.week(containing: today)[0]
        let start = Day.adding(-7 * (weeks - 1), to: monday)
        return (0..<(weeks * 7)).map { Day.adding($0, to: start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("История")
                    .font(.headline)
                Spacer()
                Text("нажмите на день, чтобы отметить")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    Text(Day.weekdaysMondayFirst[index])
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                ForEach(days, id: \.self) { day in
                    cell(for: day)
                }
            }
        }
        .card()
        .sensoryFeedback(.selection, trigger: taps)
    }

    private func cell(for day: Date) -> some View {
        let isFuture = Day.isFuture(day, relativeTo: today)
        let isToday = Day.isSameDay(day, today)
        let isDone = habit.isDone(on: day)

        return Button {
            taps += 1
            withAnimation(.snappy(duration: 0.25)) { onToggle(day) }
        } label: {
            Text(verbatim: "\(Day.dayNumber(day))")
                .font(.footnote.weight(isToday ? .bold : .regular))
                .monospacedDigit()
                .foregroundStyle(isDone ? Color.white : (isFuture ? Color.secondary.opacity(0.5) : Color.primary))
                .frame(width: 34, height: 34)
                .background(Circle().fill(isDone ? color : color.opacity(isFuture ? 0.04 : 0.1)))
                .overlay {
                    if isToday && !isDone {
                        Circle().strokeBorder(color, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}
