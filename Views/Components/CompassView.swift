import SwiftUI

// MARK: - CompassView

struct CompassView: View {
    let heading: Double
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(colors.compassRing.opacity(0.3), lineWidth: 1.5)

                // Inner background
                Circle()
                    .fill(colors.surface)
                    .padding(size * 0.06)

                // Cardinal letters — rotate opposite to heading so they appear fixed
                CardinalLabelsView(size: size, heading: heading, theme: theme)

                // North tick — fixed at top (stays with labels rotation)
                Rectangle()
                    .fill(colors.primary)
                    .frame(width: 2, height: size * 0.14)
                    .offset(y: -(size * 0.38))
                    .rotationEffect(.degrees(-heading))
                    .animation(.easeOut(duration: 0.4), value: heading)

                // Needle — always points up (indicator is fixed, map rotates around it)
                CompassNeedle(size: size, theme: theme)

                // Heading readout
                VStack(spacing: 1) {
                    Spacer()
                    Text(heading.cardinalDirection)
                        .font(.system(size: size * 0.14, weight: .bold, design: .monospaced))
                        .foregroundStyle(colors.primary)
                    Text("\(Int(heading))°")
                        .font(.system(size: size * 0.10, weight: .regular, design: .monospaced))
                        .foregroundStyle(colors.textSecondary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.3), value: heading)
                    Spacer()
                        .frame(height: size * 0.05)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - CardinalLabelsView

private struct CardinalLabelsView: View {
    let size: CGFloat
    let heading: Double
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    private let cardinals: [(label: String, angle: Double)] = [
        ("N", 0), ("NE", 45), ("E", 90), ("SE", 135),
        ("S", 180), ("SW", 225), ("W", 270), ("NW", 315)
    ]

    var body: some View {
        ZStack {
            ForEach(cardinals, id: \.angle) { item in
                let angle = (item.angle - heading) * .pi / 180
                let radius = size * 0.32
                let x = size / 2 + sin(angle) * radius
                let y = size / 2 - cos(angle) * radius

                Text(item.label)
                    .font(.system(
                        size: item.angle.truncatingRemainder(dividingBy: 90) == 0
                            ? size * 0.13
                            : size * 0.09,
                        weight: item.angle.truncatingRemainder(dividingBy: 90) == 0 ? .bold : .regular,
                        design: .monospaced
                    ))
                    .foregroundStyle(
                        item.label == "N"
                            ? colors.primary
                            : colors.text.opacity(0.7)
                    )
                    .position(x: x, y: y)
            }
        }
        .animation(.easeOut(duration: 0.4), value: heading)
    }
}

// MARK: - CompassNeedle

private struct CompassNeedle: View {
    let size: CGFloat
    let theme: MiniTheme
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            // Red tip pointing up
            Triangle()
                .fill(colors.needleColor)
                .frame(width: size * 0.06, height: size * 0.18)
                .offset(y: -(size * 0.09))

            // White tail pointing down
            Triangle()
                .fill(colors.text.opacity(0.4))
                .frame(width: size * 0.06, height: size * 0.18)
                .rotationEffect(.degrees(180))
                .offset(y: (size * 0.09))

            // Center dot
            Circle()
                .fill(colors.surface)
                .frame(width: size * 0.08, height: size * 0.08)
                .overlay(
                    Circle()
                        .strokeBorder(colors.primary, lineWidth: 1.5)
                )
        }
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    CompassView(heading: 47, theme: .goKart)
        .frame(width: 180, height: 180)
        .background(Color(hex: "#0A0A0A"))
}
