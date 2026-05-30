import SwiftUI
import CoreLocation

// MARK: - BALANCED  (Speedo 30% | Map 45% | Compass+Stats 25%)

struct BalancedModeView: View {
    @Environment(TelemetryReceiver.self) private var receiver
    @Environment(ThemeManager.self) private var themeManager

    private var telemetry: TelemetryModel? { receiver.latestTelemetry }
    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                SpeedometerView(
                    speed: telemetry?.speedKmh ?? 0,
                    maxSpeed: 240,
                    theme: themeManager.current
                )
                .frame(width: geo.size.width * 0.30, height: geo.size.height)

                columnDivider

                MapLibreView(
                    coordinate: telemetry?.coordinate ?? CLLocationCoordinate2D(),
                    heading: telemetry?.heading ?? 0
                )
                .frame(width: geo.size.width * 0.45)

                columnDivider

                VStack(spacing: 12) {
                    CompassView(
                        heading: telemetry?.heading ?? 0,
                        theme: themeManager.current
                    )
                    .frame(
                        width: min(geo.size.height * 0.46, geo.size.width * 0.20),
                        height: min(geo.size.height * 0.46, geo.size.width * 0.20)
                    )

                    VStack(spacing: 8) {
                        StatTileView(
                            label: "HEADING",
                            value: "\(Int(telemetry?.heading ?? 0))°",
                            unit: (telemetry?.heading ?? 0).cardinalDirection,
                            theme: themeManager.current,
                            systemImage: "location.north"
                        )
                        StatTileView(
                            label: "ALTITUDE",
                            value: "\(Int(telemetry?.altitude ?? 0))",
                            unit: "m",
                            theme: themeManager.current,
                            systemImage: "mountain.2"
                        )
                    }
                    .padding(.horizontal, 12)
                }
                .frame(width: geo.size.width * 0.25, height: geo.size.height)
            }
        }
    }

    private var columnDivider: some View {
        Rectangle()
            .fill(colors.primary.opacity(0.15))
            .frame(width: 1)
    }
}
