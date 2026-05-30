import SwiftUI
import MapKit

// MARK: - DashboardView

struct DashboardView: View {
    @Environment(LocationService.self) private var location
    @Environment(ThemeManager.self) private var themeManager

    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showMap: Bool = true

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        ZStack {
            // Background gradient
            themeManager.current.backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: themeManager.current)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HeaderView(theme: themeManager.current)

                    // Main speedometer — the circular centerpiece
                    SpeedometerView(
                        speed: location.speedKmh,
                        maxSpeed: 240,
                        theme: themeManager.current
                    )
                    .frame(maxWidth: 340)
                    .padding(.horizontal, 20)

                    // Compass + stats row
                    HStack(spacing: 16) {
                        CompassView(heading: location.headingDegrees, theme: themeManager.current)
                            .frame(width: 150, height: 150)

                        VStack(spacing: 10) {
                            StatTileView(
                                label: "ALTITUDE",
                                value: "\(Int(location.altitude))",
                                unit: "m",
                                theme: themeManager.current,
                                systemImage: "mountain.2"
                            )
                            StatTileView(
                                label: "HEADING",
                                value: "\(Int(location.headingDegrees))°",
                                unit: location.headingDegrees.cardinalDirection,
                                theme: themeManager.current,
                                systemImage: "location.north"
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Map toggle + map view
                    MapSectionView(
                        isExpanded: $showMap,
                        position: $mapPosition,
                        theme: themeManager.current
                    )
                    .padding(.horizontal, 20)

                    // Theme switcher
                    ThemeSwitcherView()
                        .padding(.bottom, 30)
                }
            }

            // Theme transition overlay (Mini-style "experience" announcement)
            ThemeTransitionOverlay(
                label: themeManager.transitionLabel,
                isVisible: themeManager.isTransitioning
            )
        }
        .onAppear {
            location.requestPermissionAndStart()
        }
    }
}

// MARK: - HeaderView

private struct HeaderView: View {
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        HStack {
            // Mini wordmark style
            HStack(spacing: 4) {
                Image(systemName: "car.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(colors.primary)
                Text("MINI DRIVE")
                    .font(.system(size: 16, weight: .thin, design: .monospaced))
                    .foregroundStyle(colors.text)
                    .kerning(5)
            }
            Spacer()

            // Experience name badge
            Text(theme.experienceName)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(colors.primary)
                .kerning(2)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colors.primary.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(colors.primary.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

// MARK: - MapSectionView

private struct MapSectionView: View {
    @Binding var isExpanded: Bool
    @Binding var position: MapCameraPosition
    let theme: MiniTheme

    private var colors: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 0) {
            // Toggle header
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "map")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.primary)
                    Text("MAP")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(colors.textSecondary)
                        .kerning(2)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.surface, in: RoundedRectangle(cornerRadius: isExpanded ? 16 : 16,
                                                                  style: .continuous))
            }
            .buttonStyle(.plain)

            if isExpanded {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .realistic))
                .frame(height: 220)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16,
                        topTrailingRadius: 0
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(colors.primary.opacity(0.15), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(LocationService())
        .environment(ThemeManager())
}
