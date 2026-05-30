import SwiftUI

// MARK: - ThemeSwitcherView

struct ThemeSwitcherView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MiniTheme.allCases) { theme in
                ThemeChipView(
                    theme: theme,
                    isSelected: themeManager.current == theme,
                    onTap: { themeManager.switchTo(theme) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - ThemeChipView

private struct ThemeChipView: View {
    let theme: MiniTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Color dot
                Circle()
                    .fill(theme.colors.primary)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
                    )
                    .scaleEffect(isSelected ? 1.2 : 1.0)

                // Label
                Text(theme.rawValue)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular, design: .monospaced))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}

// MARK: - ThemeTransitionOverlay

struct ThemeTransitionOverlay: View {
    let label: String
    let isVisible: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.7 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: isVisible)

            if isVisible {
                VStack(spacing: 12) {
                    Text(label)
                        .font(.system(size: 28, weight: .thin, design: .monospaced))
                        .foregroundStyle(.white)
                        .kerning(8)

                    Rectangle()
                        .fill(.white.opacity(0.4))
                        .frame(width: 60, height: 1)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .allowsHitTesting(isVisible)
    }
}
