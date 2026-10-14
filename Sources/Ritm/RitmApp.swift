import SwiftUI

@main
struct RitmApp: App {
    @StateObject private var store = HabitStore()

    var body: some Scene {
        WindowGroup {
            TodayView()
                .environmentObject(store)
                .environment(\.locale, Day.locale)
                .fontDesign(.rounded)
                .tint(Palette.accent)
        }
    }
}
