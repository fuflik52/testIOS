import Foundation

struct Habit: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var emoji: String
    var colorIndex: Int
    var createdAt = Date.now
    /// Day keys ("yyyy-MM-dd") on which the habit was done.
    var completions: Set<String> = []

    func isDone(on date: Date) -> Bool {
        completions.contains(Day.key(for: date))
    }

    mutating func toggle(on date: Date) {
        let key = Day.key(for: date)
        if completions.contains(key) {
            completions.remove(key)
        } else {
            completions.insert(key)
        }
    }

    /// Consecutive days up to today. An unchecked today doesn't break the
    /// streak yet — the day isn't over.
    func currentStreak(today: Date) -> Int {
        var day = Day.start(of: today)
        if !isDone(on: day) {
            day = Day.adding(-1, to: day)
        }
        var streak = 0
        while isDone(on: day) {
            streak += 1
            day = Day.adding(-1, to: day)
        }
        return streak
    }

    var bestStreak: Int {
        let dates = completions.compactMap(Day.date(fromKey:)).sorted()
        var best = 0
        var run = 0
        var previous: Date?
        for date in dates {
            if let previous, Day.isSameDay(Day.adding(1, to: previous), date) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            previous = date
        }
        return best
    }

    /// Share of done days among the last `count` days (only since creation).
    func completionRate(lastDays count: Int, today: Date) -> Double {
        let since = Day.start(of: createdAt)
        let days = Day.days(count, endingAt: today).filter { $0 >= since }
        guard !days.isEmpty else { return 0 }
        let done = days.filter { isDone(on: $0) }.count
        return Double(done) / Double(days.count)
    }
}
