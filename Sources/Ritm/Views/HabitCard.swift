import SwiftUI

struct HabitCard: View {
    @EnvironmentObject private var store: HabitStore

    let habit: Habit
    let today: Date

    private var color: Color { Palette.color(habit.colorIndex) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                NavigationLink(value: habit.id) {
                    HStack(spacing: 14) {
                        EmojiBadge(emoji: habit.emoji, color: color)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(habit.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            StreakLabel(streak: habit.currentStreak(today: today))
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                CheckButton(isDone: habit.isDone(on: today), color: color) {
                    store.toggle(habit.id, on: today)
                }
            }

            WeekStrip(habit: habit, today: today, color: color) { day in
                store.toggle(habit.id, on: day)
            }
        }
        .card()
    }
}

struct StreakLabel: View {
    let streak: Int

    var body: some View {
        if streak > 0 {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text(Russian.days(streak) + " подряд")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        } else {
            Text("Начните сегодня")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

/// Monday…Sunday of the current week; past days can be tapped to fix a mark.
struct WeekStrip: View {
    let habit: Habit
    let today: Date
    let color: Color
    let onToggle: (Date) -> Void

    @State private var taps = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Day.week(containing: today), id: \.self) { day in
                let isFuture = Day.isFuture(day, relativeTo: today)
                let isToday = Day.isSameDay(day, today)
                let isDone = habit.isDone(on: day)

                Button {
                    taps += 1
                    withAnimation(.snappy(duration: 0.25)) { onToggle(day) }
                } label: {
                    VStack(spacing: 6) {
                        Text(Day.weekdayShort(day))
                            .font(.caption2.weight(isToday ? .bold : .medium))
                            .foregroundStyle(isToday ? Color.primary : Color.secondary)
                        Circle()
                            .fill(isDone ? color : color.opacity(isFuture ? 0.05 : 0.14))
                            .overlay {
                                if isToday && !isDone {
                                    Circle().strokeBorder(color, lineWidth: 1.5)
                                }
                            }
                            .frame(width: 22, height: 22)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
            }
        }
        .sensoryFeedback(.selection, trigger: taps)
    }
}
