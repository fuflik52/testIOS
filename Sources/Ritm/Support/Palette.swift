import SwiftUI

struct HabitIdea {
    let emoji: String
    let title: String
}

enum Palette {
    static let accent = Color(red: 0.33, green: 0.65, blue: 0.56)

    /// Soft tones that read well on both light and dark backgrounds.
    static let colors: [Color] = [
        Color(red: 0.33, green: 0.65, blue: 0.56), // шалфей
        Color(red: 0.36, green: 0.60, blue: 0.92), // небо
        Color(red: 0.96, green: 0.58, blue: 0.42), // персик
        Color(red: 0.60, green: 0.50, blue: 0.90), // лаванда
        Color(red: 0.93, green: 0.46, blue: 0.58), // роза
        Color(red: 0.91, green: 0.69, blue: 0.27), // мёд
        Color(red: 0.27, green: 0.69, blue: 0.76), // мята
        Color(red: 0.50, green: 0.52, blue: 0.58), // графит
    ]

    static func color(_ index: Int) -> Color {
        colors[((index % colors.count) + colors.count) % colors.count]
    }

    static let emojis = [
        "💧", "🚶", "📖", "🧘", "🏃", "💪",
        "🥗", "🍎", "😴", "🌙", "☀️", "🧠",
        "✍️", "🎸", "🎨", "🌱", "🧹", "💊",
        "🦷", "📵", "🙏", "💻", "🗣️", "💰",
    ]

    static let ideas = [
        HabitIdea(emoji: "💧", title: "Стакан воды утром"),
        HabitIdea(emoji: "🚶", title: "Прогулка 20 минут"),
        HabitIdea(emoji: "📖", title: "Читать 10 страниц"),
        HabitIdea(emoji: "🧘", title: "5 минут тишины"),
        HabitIdea(emoji: "😴", title: "Лечь до полуночи"),
        HabitIdea(emoji: "📵", title: "Утро без телефона"),
        HabitIdea(emoji: "✍️", title: "Три строчки в дневник"),
    ]
}
