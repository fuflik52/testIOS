import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = Date.now
    @State private var isCreating = false
    @State private var editingHabit: Habit?

    private var doneCount: Int {
        store.habits.filter { $0.isDone(on: today) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if store.habits.isEmpty {
                        emptyState
                    } else {
                        SummaryCard(done: doneCount, total: store.habits.count)

                        VStack(spacing: 12) {
                            ForEach(store.habits) { habit in
                                HabitCard(habit: habit, today: today)
                                    .contentShape(
                                        .contextMenuPreview,
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    )
                                    .contextMenu { menu(for: habit) }
                                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreating = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Новая привычка")
                }
            }
            .navigationDestination(for: UUID.self) { id in
                HabitDetailView(habitID: id, today: today)
            }
            .sheet(isPresented: $isCreating) {
                HabitEditor(mode: .create)
            }
            .sheet(item: $editingHabit) { habit in
                HabitEditor(mode: .edit(habit))
            }
            .onChange(of: scenePhase) { _, phase in
                // The app may sit in the background overnight.
                if phase == .active { today = .now }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(today.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Day.locale)))
                .font(.footnote.weight(.semibold))
                .textCase(.uppercase)
                .tracking(0.6)
                .foregroundStyle(.secondary)
            Text(greeting)
                .font(.largeTitle.bold())
        }
        .padding(.top, 4)
    }

    private var greeting: String {
        switch Day.calendar.component(.hour, from: today) {
        case 5..<12: "Доброе утро"
        case 12..<18: "Добрый день"
        case 18..<23: "Добрый вечер"
        default: "Доброй ночи"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("🌱")
                .font(.system(size: 56))
            Text("Пока пусто")
                .font(.title3.bold())
            Text("Добавьте первую привычку —\nмаленький шаг каждый день.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                isCreating = true
            } label: {
                Text("Добавить привычку")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    @ViewBuilder
    private func menu(for habit: Habit) -> some View {
        Button("Изменить", systemImage: "pencil") {
            editingHabit = habit
        }
        Button("Удалить", systemImage: "trash", role: .destructive) {
            withAnimation(.snappy) { store.delete(habit.id) }
        }
    }
}

private struct SummaryCard: View {
    let done: Int
    let total: Int

    private var progress: Double {
        total == 0 ? 0 : Double(done) / Double(total)
    }

    private var subtitle: String {
        let left = total - done
        if left == 0 { return "Всё сделано — так держать ✨" }
        return "Ещё \(left) \(Russian.plural(left, "привычка", "привычки", "привычек")) на сегодня"
    }

    var body: some View {
        HStack(spacing: 18) {
            ProgressRing(progress: progress, color: Palette.accent, lineWidth: 9)
                .frame(width: 64, height: 64)
                .overlay {
                    Text(verbatim: "\(Int((progress * 100).rounded()))%")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "\(done) из \(total)")
                    .font(.title2.bold())
                    .contentTransition(.numericText())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .card()
        .animation(.snappy, value: done)
    }
}
