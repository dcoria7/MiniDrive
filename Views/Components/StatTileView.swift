import SwiftUI

// MARK: - StatTileView

struct StatTileView: View {
    let label: String
    let value: String
    let unit: String
    let theme: MiniTheme
    let systemImage: String

    private var colors: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Icon + label
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(colors.primary)
                Text(label)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textSecondary)
                    .kerning(1.5)
            }

            // Value
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(colors.text)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: value)

                Text(unit)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(colors.primary.opacity(0.22), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    StatTileView(
        label: "ALTITUDE",
        value: "142",
        unit: "m",
        theme: .goKart,
        systemImage: "mountain.2"
    )
    .frame(width: 160)
    .background(Color(hex: "#0A0A0A"))
}
