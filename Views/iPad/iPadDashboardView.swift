import SwiftUI

struct iPadDashboardView: View {
    @Environment(TelemetryReceiver.self) private var receiver
    @Environment(ThemeManager.self) private var themeManager
    @State private var currentMode: CarPlayMode = .balanced
    @State private var showModePicker = false

    private var colors: ThemeColors { themeManager.current.colors }

    var body: some View {
        ZStack {
            themeManager.current.backgroundGradient.ignoresSafeArea()

            if receiver.isConnected {
                modeContent
                    .animation(.easeInOut(duration: 0.35), value: currentMode)
                    .transition(.opacity)
            } else {
                waitingView
            }

            // Mode switcher — bottom trailing corner
            modeSwitcher
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(20)

            // Theme transition overlay
            ThemeTransitionOverlay(
                label: themeManager.transitionLabel,
                isVisible: themeManager.isTransitioning
            )
        }
        .onAppear { receiver.start() }
        .onDisappear { receiver.stop() }
    }

    // MARK: - Mode content

    @ViewBuilder
    private var modeContent: some View {
        switch currentMode {
        case .balanced:   BalancedModeView()
        case .mapFocus:   MapFocusView()
        case .speedFocus: SpeedFocusView()
        }
    }

    // MARK: - Waiting view

    private var waitingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(colors.primary)

            Text("WAITING FOR iPHONE")
                .font(.system(size: 18, weight: .thin, design: .monospaced))
                .foregroundStyle(colors.text)
                .kerning(4)

            Text("Open MiniDrive on your iPhone\nand make sure Wi-Fi is enabled.")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(60)
    }

    // MARK: - Mode switcher

    private var modeSwitcher: some View {
        Menu {
            ForEach(CarPlayMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        currentMode = mode
                    }
                } label: {
                    Label(mode.rawValue, systemImage: modeIcon(for: mode))
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: modeIcon(for: currentMode))
                    .font(.system(size: 13, weight: .medium))
                Text(currentMode.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .kerning(1.5)
            }
            .foregroundStyle(colors.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(colors.surface.opacity(0.85), in: Capsule())
            .overlay(Capsule().strokeBorder(colors.primary.opacity(0.25), lineWidth: 1))
        }
    }

    private func modeIcon(for mode: CarPlayMode) -> String {
        switch mode {
        case .balanced:   return "square.grid.3x1.below.line.grid.1x2"
        case .mapFocus:   return "map"
        case .speedFocus: return "speedometer"
        }
    }
}
