import SwiftUI

// MARK: - CarPlayDashboardOverlayView
/// Compact Mini-style dashboard designed for the CarPlay screen.
/// Landscape-first layout: speedometer left, compass + stats right.

struct CarPlayDashboardOverlayView: View {
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        ZStack {
            // Background
            themeManager.current.backgroundGradient
                .ignoresSafeArea()

            GeometryReader { geo in
                HStack(spacing: 0) {
                    // LEFT — Main speedometer
                    SpeedometerView(
                        speed: location.speedKmh,
                        maxSpeed: 240,
                        theme: themeManager.current
                    )
                    .frame(width: geo.size.height * 0.9,
                           height: geo.size.height * 0.9)
                    .padding(.leading, 12)

                    Divider()
                        .background(colors.primary.opacity(0.2))
                        .padding(.vertical, 20)

                    // RIGHT — Compass + stats
                    VStack(spacing: 16) {
                        // Compass
                        CompassView(
                            heading: location.headingDegrees,
                            theme: themeManager.current
                        )
                        .frame(width: geo.size.height * 0.38,
                               height: geo.size.height * 0.38)

                        Divider()
                            .background(colors.primary.opacity(0.15))
                            .padding(.horizontal, 10)

                        // Stats
                        CarPlayStatsRowView(
                            heading: location.headingDegrees,
                            altitude: location.altitude,
                            theme: themeManager.current
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
            }

            // Theme transition overlay
            ThemeTransitionOverlay(
                label: themeManager.transitionLabel,
                isVisible: themeManager.isTransitioning
            )
        }
    }
}

// MARK: - CarPlayStatsRowView

private struct CarPlayStatsRowView: View {
    let heading: Double
    let altitude: Double
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        HStack(spacing: 12) {
            CarPlayStatCell(
                label: "HDG",
                value: "\(Int(heading))°",
                sub: heading.cardinalDirection,
                theme: theme,
                icon: "location.north.fill"
            )
            CarPlayStatCell(
                label: "ALT",
                value: "\(Int(altitude))",
                sub: "m",
                theme: theme,
                icon: "mountain.2.fill"
            )
        }
    }
}

// MARK: - CarPlayStatCell

private struct CarPlayStatCell: View {
    let label: String
    let value: String
    let sub: String
    let theme: MiniTheme
    let icon: String
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(label, systemImage: icon)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(colors.primary)
                .kerning(1)

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundStyle(colors.text)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: value)

                Text(sub)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(colors.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(colors.surface.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview("CarPlay Landscape") {
    CarPlayDashboardOverlayView()
        .environment(LocationService())
        .environment(ThemeManager())
        .frame(width: 800, height: 480)
}
