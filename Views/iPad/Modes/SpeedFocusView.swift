import SwiftUI

// MARK: - SPEED FOCUS  (Speedo 58% | Compass+Stats 42%)

struct SpeedFocusView: View {
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
                .frame(width: geo.size.width * 0.58, height: geo.size.height)

                Rectangle()
                    .fill(colors.primary.opacity(0.15))
                    .frame(width: 1)

                VStack(spacing: 20) {
                    CompassView(
                        heading: telemetry?.heading ?? 0,
                        theme: themeManager.current
                    )
                    .frame(
                        width: geo.size.height * 0.50,
                        height: geo.size.height * 0.50
                    )

                    VStack(spacing: 10) {
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
                        StatTileView(
                            label: "SPEED",
                            value: "\(Int(telemetry?.speedKmh ?? 0))",
                            unit: "km/h",
                            theme: themeManager.current,
                            systemImage: "speedometer"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
