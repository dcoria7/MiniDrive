import SwiftUI
import MapKit

// MARK: - CarPlayDashboardView
// Mode-aware dashboard for CarPlay (1280×480, Mazda CX-30 2023)

struct CarPlayDashboardView: View {
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager
    @Environment(CarPlayState.self) private var carPlayState

    var body: some View {
        GeometryReader { geo in
            ZStack {
                themeManager.current.backgroundGradient.ignoresSafeArea()

                Group {
                    switch carPlayState.currentMode {
                    case .balanced:
                        BalancedLayout(geo: geo)
                    case .mapFocus:
                        MapFocusLayout(geo: geo)
                    case .speedFocus:
                        SpeedFocusLayout(geo: geo)
                    }
                }
                .id(carPlayState.currentMode)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .padding(.top, 36)

                ThemeTransitionOverlay(
                    label: themeManager.transitionLabel,
                    isVisible: themeManager.isTransitioning
                )
            }
        }
    }
}

// MARK: - BALANCED  (Speedo 32% | Map 42% | Compass+Stats 26%)

private struct BalancedLayout: View {
    let geo: GeometryProxy
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        HStack(spacing: 0) {
            SpeedometerView(speed: location.speedKmh, maxSpeed: 240, theme: themeManager.current)
                .frame(width: geo.size.width * 0.32, height: geo.size.height)

            columnDivider

            Map(position: .constant(.userLocation(fallback: .automatic))) {
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(width: geo.size.width * 0.42)
            .disabled(true)

            columnDivider

            VStack(spacing: 10) {
                CompassView(heading: location.headingDegrees, theme: themeManager.current)
                    .frame(width: geo.size.height * 0.46, height: geo.size.height * 0.46)
                HStack(spacing: 6) {
                    StatTileView(
                        label: "HDG",
                        value: "\(Int(location.headingDegrees))°",
                        unit: location.headingDegrees.cardinalDirection,
                        theme: themeManager.current,
                        systemImage: "location.north"
                    )
                    StatTileView(
                        label: "ALT",
                        value: "\(Int(location.altitude))",
                        unit: "m",
                        theme: themeManager.current,
                        systemImage: "mountain.2"
                    )
                }
                .padding(.horizontal, 8)
            }
            .frame(width: geo.size.width * 0.26, height: geo.size.height)
        }
    }

    private var columnDivider: some View {
        Rectangle()
            .fill(colors.primary.opacity(0.15))
            .frame(width: 1)
    }
}

// MARK: - MAP FOCUS  (Speed strip 17% | Map 83%)

private struct MapFocusLayout: View {
    let geo: GeometryProxy
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Spacer()
                Text("\(Int(location.speedKmh))")
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    .foregroundStyle(colors.text)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.25), value: location.speedKmh)
                Text("km/h")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(colors.primary)
                    .kerning(1)
                Spacer()
                Rectangle()
                    .fill(colors.primary.opacity(0.3))
                    .frame(width: 28, height: 1)
                Text(location.headingDegrees.cardinalDirection)
                    .font(.system(size: 18, weight: .thin, design: .monospaced))
                    .foregroundStyle(colors.textSecondary)
                    .padding(.bottom, 4)
                Spacer()
            }
            .frame(width: geo.size.width * 0.17)
            .background(colors.surface)

            Map(position: .constant(.userLocation(fallback: .automatic))) {
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(width: geo.size.width * 0.83)
            .disabled(true)
        }
    }
}

// MARK: - SPEED FOCUS  (Speedo 62% | Compass+Stats 38%)

private struct SpeedFocusLayout: View {
    let geo: GeometryProxy
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        HStack(spacing: 0) {
            SpeedometerView(speed: location.speedKmh, maxSpeed: 240, theme: themeManager.current)
                .frame(width: geo.size.width * 0.62, height: geo.size.height)

            Rectangle()
                .fill(colors.primary.opacity(0.15))
                .frame(width: 1)

            VStack(spacing: 14) {
                CompassView(heading: location.headingDegrees, theme: themeManager.current)
                    .frame(width: geo.size.height * 0.52, height: geo.size.height * 0.52)
                HStack(spacing: 10) {
                    StatTileView(
                        label: "HDG",
                        value: "\(Int(location.headingDegrees))°",
                        unit: location.headingDegrees.cardinalDirection,
                        theme: themeManager.current,
                        systemImage: "location.north"
                    )
                    StatTileView(
                        label: "ALT",
                        value: "\(Int(location.altitude))",
                        unit: "m",
                        theme: themeManager.current,
                        systemImage: "mountain.2"
                    )
                }
                .padding(.horizontal, 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#Preview("BALANCED · 1280×480") {
    CarPlayDashboardView()
        .environment(LocationService())
        .environment(ThemeManager())
        .environment(CarPlayState())
        .frame(width: 1280, height: 480)
}

#Preview("MAP FOCUS · 1280×480") {
    let state = CarPlayState()
    state.currentMode = .mapFocus
    return CarPlayDashboardView()
        .environment(LocationService())
        .environment(ThemeManager())
        .environment(state)
        .frame(width: 1280, height: 480)
}

#Preview("SPEED FOCUS · 1280×480") {
    let state = CarPlayState()
    state.currentMode = .speedFocus
    return CarPlayDashboardView()
        .environment(LocationService())
        .environment(ThemeManager())
        .environment(state)
        .frame(width: 1280, height: 480)
}
