import SwiftUI

struct EmojiBadge: View {
    let emoji: String
    let color: Color
    var size: CGFloat = 48

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.5))
            .frame(width: size, height: size)
            .background(
                color.opacity(0.16),
                in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
            )
    }
}

struct ProgressRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(.snappy, value: progress)
    }
}

struct SectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.6)
            .foregroundStyle(.secondary)
    }
}

/// Round "done" button with a check mark.
struct CheckButton: View {
    let isDone: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.3)) { action() }
        } label: {
            ZStack {
                Circle()
                    .fill(isDone ? color : .clear)
                Circle()
                    .strokeBorder(color.opacity(isDone ? 0 : 0.35), lineWidth: 2)
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isDone ? Color.white : color.opacity(0.35))
            }
            .frame(width: 46, height: 46)
            .scaleEffect(isDone ? 1 : 0.94)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isDone) { _, done in
            done ? SensoryFeedback.success : .impact(weight: .light)
        }
        .accessibilityLabel("Отметить")
        .accessibilityValue(isDone ? "Выполнено" : "Не выполнено")
    }
}

struct StatTile: View {
    let value: String
    let caption: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }
}

extension View {
    /// Rounded card on the grouped background.
    func card(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
    }
}
