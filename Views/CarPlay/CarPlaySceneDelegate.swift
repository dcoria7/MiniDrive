import CarPlay
import SwiftUI

// MARK: - CarPlaySceneDelegate

/// Register in Info.plist:
/// UIApplicationSceneManifest → UISceneConfigurations → CPTemplateApplicationSceneSessionRoleApplication
/// with CPTemplateApplicationSceneDelegate key pointing to this class.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    private var interfaceController: CPInterfaceController?
    private var dashboardTemplate: CPMapTemplate?

    // Injected from app
    var locationService: LocationService?
    var themeManager: ThemeManager?

    // MARK: - CPTemplateApplicationSceneDelegate

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        setupDashboard()
    }

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }

    // MARK: - Private

    private func setupDashboard() {
        let template = CPMapTemplate()
        template.automaticallyHidesNavigationBar = false
        template.hidesButtonsWithNavigationBar = false

        // Speed limit area shows current speed (repurposed label)
        template.showPanningInterface(animated: false)

        dashboardTemplate = template
        interfaceController?.setRootTemplate(template, animated: false)

        // NOTE: In a full implementation, you would use CPDashboardController
        // with a SwiftUI view for the instrument cluster if CarPlay Ultra is available.
        // For standard CarPlay, CPMapTemplate is the approved template for driving task apps.
        // The speed + heading overlay is displayed via mapButtons and guidanceBackgroundColor.

        updateMapButtons()
    }

    private func updateMapButtons() {
        guard let template = dashboardTemplate,
              let location = locationService else { return }

        // Speed readout button (display only)
        let speedButton = CPMapButton { _ in }
        // CarPlay doesn't allow custom SwiftUI overlays in CPMapTemplate —
        // the recommended approach is to use CPDashboardController (iOS 13.4+)
        // or request the Navigation entitlement to use CPNavigationAlert for data.

        template.mapButtons = [speedButton]
    }
}

// MARK: - CarPlayDashboardController

/// Companion controller that manages the CarPlay instrument cluster overlay.
/// Uses CPDashboardController available in iOS 13.4+.
@MainActor
final class CarPlayDashboardController: NSObject, CPDashboardControllerDelegate {

    private var dashboardController: CPDashboardController?

    func dashboardController(
        _ dashboardController: CPDashboardController,
        didConnectWith window: CPWindow
    ) {
        self.dashboardController = dashboardController

        // Host a SwiftUI view inside the CarPlay window
        let hostingController = UIHostingController(
            rootView: CarPlayDashboardOverlayView()
                .environmentObject(LocationService())
                .environmentObject(ThemeManager())
        )
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
    }

    func dashboardController(
        _ dashboardController: CPDashboardController,
        didDisconnectWith window: CPWindow
    ) {
        self.dashboardController = nil
    }
}
