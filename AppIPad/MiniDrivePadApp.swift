import SwiftUI

@main
struct MiniDrivePadApp: App {
    @State private var receiver = TelemetryReceiver()
    @State private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            iPadDashboardView()
                .environment(receiver)
                .environment(theme)
        }
    }
}
