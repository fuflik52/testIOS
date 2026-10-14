import Foundation

/// Calendar helpers. Completions are stored as "yyyy-MM-dd" keys, so a mark
/// always belongs to a calendar day regardless of time zone changes.
enum Day {
    static let locale = Locale(identifier: "ru_RU")

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.firstWeekday = 2 // понедельник
        return calendar
    }()

    /// «Пн», «Вт» … «Вс».
    static let weekdaysMondayFirst: [String] = {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return (Array(symbols[1...]) + [symbols[0]]).map(\.capitalizedFirst)
    }()

    static func start(of date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func adding(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: start(of: date)) ?? date
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func isFuture(_ date: Date, relativeTo today: Date) -> Bool {
        start(of: date) > start(of: today)
    }

    static func key(for date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return [
            padded(parts.year ?? 0, to: 4),
            padded(parts.month ?? 0, to: 2),
            padded(parts.day ?? 0, to: 2),
        ].joined(separator: "-")
    }

    static func date(fromKey key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    /// `count` days ending with `date`, oldest first.
    static func days(_ count: Int, endingAt date: Date) -> [Date] {
        (0..<count).reversed().map { adding(-$0, to: date) }
    }

    /// Monday…Sunday of the week that contains `date`.
    static func week(containing date: Date) -> [Date] {
        let monday = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? start(of: date)
        return (0..<7).map { adding($0, to: monday) }
    }

    static func weekdayShort(_ date: Date) -> String {
        let index = calendar.component(.weekday, from: date) - 1
        return calendar.shortStandaloneWeekdaySymbols[index].capitalizedFirst
    }

    static func dayNumber(_ date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    private static func padded(_ value: Int, to width: Int) -> String {
        let digits = String(value)
        return String(repeating: "0", count: max(0, width - digits.count)) + digits
    }
}

enum Russian {
    /// plural(5, "день", "дня", "дней") → "дней"
    static func plural(_ n: Int, _ one: String, _ few: String, _ many: String) -> String {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 { return one }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return few }
        return many
    }

    static func days(_ n: Int) -> String {
        "\(n) \(plural(n, "день", "дня", "дней"))"
    }
}

extension String {
    var capitalizedFirst: String {
        prefix(1).uppercased() + String(dropFirst())
    }
}
