import SwiftUI

// MARK: - MiniTheme

enum MiniTheme: String, CaseIterable, Identifiable {
    case goKart    = "Go-Kart"
    case timeless  = "Timeless"
    case vivid     = "Vivid"
    case iceBlue   = "Ice Blue"

    var id: String { rawValue }

    var colors: ThemeColors {
        switch self {
        case .goKart:
            return ThemeColors(
                background: Color(hex: "#0A0A0A"),
                surface: Color(hex: "#141414"),
                primary: Color(hex: "#E8FF00"),       // Mini Go-Kart yellow-green
                secondary: Color(hex: "#FF4500"),
                text: Color(hex: "#F5F5F5"),
                textSecondary: Color(hex: "#888888"),
                speedArc: Color(hex: "#E8FF00"),
                needleColor: Color(hex: "#FF4500"),
                compassRing: Color(hex: "#E8FF00")
            )
        case .timeless:
            return ThemeColors(
                background: Color(hex: "#1A1208"),
                surface: Color(hex: "#241A0A"),
                primary: Color(hex: "#C8A96E"),       // Mini classic chrome/gold
                secondary: Color(hex: "#8B6914"),
                text: Color(hex: "#F0E8D8"),
                textSecondary: Color(hex: "#9A8870"),
                speedArc: Color(hex: "#C8A96E"),
                needleColor: Color(hex: "#FF6B35"),
                compassRing: Color(hex: "#C8A96E")
            )
        case .vivid:
            return ThemeColors(
                background: Color(hex: "#0D0D1A"),
                surface: Color(hex: "#12122A"),
                primary: Color(hex: "#FF2D78"),       // Mini Vivid hot pink
                secondary: Color(hex: "#7B2FFF"),
                text: Color(hex: "#F0F0FF"),
                textSecondary: Color(hex: "#8888AA"),
                speedArc: Color(hex: "#FF2D78"),
                needleColor: Color(hex: "#7B2FFF"),
                compassRing: Color(hex: "#FF2D78")
            )
        case .iceBlue:
            return ThemeColors(
                background: Color(hex: "#050E1A"),
                surface: Color(hex: "#0A1628"),
                primary: Color(hex: "#00C8FF"),       // Ice Blue
                secondary: Color(hex: "#0066CC"),
                text: Color(hex: "#E0F4FF"),
                textSecondary: Color(hex: "#6699AA"),
                speedArc: Color(hex: "#00C8FF"),
                needleColor: Color(hex: "#FFFFFF"),
                compassRing: Color(hex: "#00C8FF")
            )
        }
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [colors.background, colors.surface],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Jingle/experience name shown during theme switch animation
    var experienceName: String {
        switch self {
        case .goKart:   return "GO-KART MODE"
        case .timeless: return "TIMELESS"
        case .vivid:    return "VIVID"
        case .iceBlue:  return "ICE BLUE"
        }
    }
}

// MARK: - ThemeColors

struct ThemeColors {
    let background: Color
    let surface: Color
    let primary: Color
    let secondary: Color
    let text: Color
    let textSecondary: Color
    let speedArc: Color
    let needleColor: Color
    let compassRing: Color
}

// MARK: - ThemeManager

@Observable
@MainActor
final class ThemeManager {
    private(set) var current: MiniTheme = .goKart
    private(set) var isTransitioning: Bool = false
    private(set) var transitionLabel: String = ""

    func switchTo(_ theme: MiniTheme) {
        guard theme != current else { return }
        isTransitioning = true
        transitionLabel = theme.experienceName

        withAnimation(.easeInOut(duration: 0.6)) {
            current = theme
        }

        Task {
            try? await Task.sleep(for: .seconds(1.4))
            isTransitioning = false
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
