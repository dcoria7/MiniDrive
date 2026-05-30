import SwiftUI

// MARK: - SpeedometerView

struct SpeedometerView: View {

    let speed: Double
    let maxSpeed: Double
    let theme: MiniTheme

    private var colors: ThemeColors { theme.colors }

    /// Arc goes from -225° to 45°  (270° sweep), starting bottom-left
    private let startAngle: Double = -225
    private let totalSweep: Double = 270

    private var progressAngle: Double {
        let ratio = min(speed / maxSpeed, 1.0)
        return startAngle + totalSweep * ratio
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let outerR = size / 2 * 0.92
            let arcWidth: CGFloat = size * 0.045

            ZStack {
                // Outer ring — subtle border
                Circle()
                    .strokeBorder(colors.primary.opacity(0.15), lineWidth: 1.5)

                // Background arc track
                ArcShape(
                    startAngle: startAngle,
                    endAngle: startAngle + totalSweep
                )
                .stroke(colors.surface, lineWidth: arcWidth)
                .frame(width: outerR * 2, height: outerR * 2)
                .position(center)

                // Active speed arc
                ArcShape(
                    startAngle: startAngle,
                    endAngle: progressAngle
                )
                .stroke(
                    LinearGradient(
                        colors: [colors.speedArc.opacity(0.6), colors.speedArc],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: arcWidth, lineCap: .round)
                )
                .frame(width: outerR * 2, height: outerR * 2)
                .position(center)
                .animation(.easeOut(duration: 0.3), value: speed)

                // Tick marks
                TickMarksView(
                    size: size,
                    center: center,
                    outerR: outerR,
                    startAngle: startAngle,
                    totalSweep: totalSweep,
                    maxSpeed: maxSpeed,
                    theme: theme
                )

                // Speed numerals around arc
                SpeedNumeralsView(
                    size: size,
                    center: center,
                    radius: outerR * 0.78,
                    startAngle: startAngle,
                    totalSweep: totalSweep,
                    maxSpeed: maxSpeed,
                    theme: theme
                )

                // Center display
                CenterReadoutView(speed: speed, theme: theme)
                    .position(center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - ArcShape

private struct ArcShape: Shape {
    var startAngle: Double
    var endAngle: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle, endAngle) }
        set {
            startAngle = newValue.first
            endAngle = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return p
    }
}

// MARK: - TickMarksView

private struct TickMarksView: View {
    let size: CGFloat
    let center: CGPoint
    let outerR: CGFloat
    let startAngle: Double
    let totalSweep: Double
    let maxSpeed: Double
    let theme: MiniTheme

    private var colors: ThemeColors { theme.colors }

    var body: some View {
        Canvas { context, _ in
            let majorCount = Int(maxSpeed / 20)                // every 20 km/h
            let minorPerMajor = 4                               // 4 minor ticks between majors

            for major in 0...majorCount {
                let ratio = Double(major) / Double(majorCount)
                let angle = (startAngle + totalSweep * ratio) * .pi / 180
                drawTick(context: context, angle: angle, isMajor: true)

                if major < majorCount {
                    for minor in 1..<minorPerMajor {
                        let minorRatio = ratio + (1.0 / Double(majorCount)) * (Double(minor) / Double(minorPerMajor))
                        let minorAngle = (startAngle + totalSweep * minorRatio) * .pi / 180
                        drawTick(context: context, angle: minorAngle, isMajor: false)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .position(center)
    }

    private func drawTick(context: GraphicsContext, angle: Double, isMajor: Bool) {
        let innerR = outerR * (isMajor ? 0.82 : 0.87)
        let tickR  = outerR * 0.90
        let cx = size / 2
        let cy = size / 2

        let x1 = cx + cos(angle) * innerR
        let y1 = cy + sin(angle) * innerR
        let x2 = cx + cos(angle) * tickR
        let y2 = cy + sin(angle) * tickR

        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))

        context.stroke(
            path,
            with: .color(isMajor ? colors.primary.opacity(0.8) : colors.textSecondary.opacity(0.4)),
            lineWidth: isMajor ? 2 : 1
        )
    }
}

// MARK: - SpeedNumeralsView

private struct SpeedNumeralsView: View {
    let size: CGFloat
    let center: CGPoint
    let radius: CGFloat
    let startAngle: Double
    let totalSweep: Double
    let maxSpeed: Double
    let theme: MiniTheme

    private var colors: ThemeColors { theme.colors }
    private let steps: [Int] = [0, 40, 80, 120, 160, 200, 240]

    var body: some View {
        ZStack {
            ForEach(steps, id: \.self) { value in
                let ratio = Double(value) / maxSpeed
                let angle = (startAngle + totalSweep * ratio) * .pi / 180
                let x = size / 2 + cos(angle) * radius
                let y = size / 2 + sin(angle) * radius

                Text("\(value)")
                    .font(.system(size: size * 0.052, weight: .medium, design: .monospaced))
                    .foregroundStyle(colors.textSecondary)
                    .position(x: x, y: y)
            }
        }
        .frame(width: size, height: size)
        .position(center)
    }
}

// MARK: - CenterReadoutView

private struct CenterReadoutView: View {
    let speed: Double
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 2) {
            // Big speed number
            Text("\(Int(speed))")
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundStyle(colors.text)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: speed)

            Text("km/h")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(colors.primary)
                .kerning(4)
        }
    }
}

// MARK: - Preview

#Preview {
    SpeedometerView(speed: 85, maxSpeed: 240, theme: .goKart)
        .frame(width: 340, height: 340)
        .background(Color(hex: "#0A0A0A"))
}
