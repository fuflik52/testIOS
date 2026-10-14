import Combine
import Foundation

/// Keeps habits in memory and mirrors them to a JSON file in Documents.
@MainActor
final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []

    private let fileURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("habits.json")
        load()
    }

    func habit(id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }

    func add(title: String, emoji: String, colorIndex: Int) {
        habits.append(Habit(title: title, emoji: emoji, colorIndex: colorIndex))
        save()
    }

    func update(_ id: UUID, _ change: (inout Habit) -> Void) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        change(&habits[index])
        save()
    }

    func toggle(_ id: UUID, on date: Date) {
        update(id) { $0.toggle(on: date) }
    }

    func delete(_ id: UUID) {
        habits.removeAll { $0.id == id }
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // First launch: a few example habits so the app doesn't look empty.
            habits = Self.samples()
            save()
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            habits = try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            print("Не удалось прочитать привычки: \(error)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(habits)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Не удалось сохранить привычки: \(error)")
        }
    }

    private static func samples() -> [Habit] {
        let presets: [(title: String, emoji: String, color: Int)] = [
            ("Стакан воды утром", "💧", 1),
            ("Прогулка 20 минут", "🚶", 0),
            ("Читать 10 страниц", "📖", 3),
            ("Лечь до полуночи", "🌙", 5),
        ]
        let today = Date.now
        return presets.enumerated().map { index, preset in
            var habit = Habit(
                title: preset.title,
                emoji: preset.emoji,
                colorIndex: preset.color,
                createdAt: Day.adding(-24, to: today)
            )
            for offset in 1...24 where (offset * (index + 2) + index) % 5 != 0 {
                habit.completions.insert(Day.key(for: Day.adding(-offset, to: today)))
            }
            if index == 0 {
                habit.completions.insert(Day.key(for: today))
            }
            return habit
        }
    }
}
