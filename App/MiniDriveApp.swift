import SwiftUI

@main
struct MiniDriveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var locationService = LocationService()
    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationService)
                .environment(themeManager)
        }
    }
}
