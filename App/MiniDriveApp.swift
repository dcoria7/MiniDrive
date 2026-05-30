import SwiftUI

@main
struct MiniDriveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDelegate.locationService)
                .environment(appDelegate.themeManager)
        }
    }
}
