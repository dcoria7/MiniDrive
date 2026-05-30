import SwiftUI

@main
struct MiniDrivePadApp: App {
    @State private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            Text("iPad Dashboard — Módulo 3")
                .font(.system(.title, design: .monospaced, weight: .thin))
                .foregroundStyle(theme.current.colors.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.current.colors.background)
                .environment(theme)
        }
    }
}
