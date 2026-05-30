import SwiftUI
import CoreLocation

// MARK: - MAP FOCUS  (Speed strip 18% | Map 82%)

struct MapFocusView: View {
    @Environment(TelemetryReceiver.self) private var receiver
    @Environment(ThemeManager.self) private var themeManager

    private var telemetry: TelemetryModel? { receiver.latestTelemetry }
    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Speed strip
                VStack(spacing: 6) {
                    Spacer()
                    Text("\(Int(telemetry?.speedKmh ?? 0))")
                        .font(.system(size: 62, weight: .thin, design: .monospaced))
                        .foregroundStyle(colors.text)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.25), value: telemetry?.speedKmh)
                    Text("km/h")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(colors.primary)
                        .kerning(1)
                    Spacer()
                    Rectangle()
                        .fill(colors.primary.opacity(0.3))
                        .frame(width: 32, height: 1)
                    Text((telemetry?.heading ?? 0).cardinalDirection)
                        .font(.system(size: 20, weight: .thin, design: .monospaced))
                        .foregroundStyle(colors.textSecondary)
                        .padding(.bottom, 8)
                    Spacer()
                }
                .frame(width: geo.size.width * 0.18)
                .background(colors.surface)

                MapLibreView(
                    coordinate: telemetry?.coordinate ?? CLLocationCoordinate2D(),
                    heading: telemetry?.heading ?? 0
                )
                .frame(width: geo.size.width * 0.82)
            }
        }
    }
}
