@preconcurrency import CarPlay
import SwiftUI

@MainActor
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    private var interfaceController: CPInterfaceController?
    private let carPlayState = CarPlayState()

    // MARK: - CPTemplateApplicationSceneDelegate

    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // CPMapTemplate is required for the carplay-driving-task entitlement
        let mapTemplate = CPMapTemplate()
        mapTemplate.automaticallyHidesNavigationBar = false
        mapTemplate.trailingNavigationBarButtons = [makeModeButton(controller: interfaceController)]
        interfaceController.setRootTemplate(mapTemplate, animated: false)

        // Host SwiftUI dashboard on the CarPlay window
        let dashboardView = CarPlayDashboardView()
            .environment(delegate.locationService)
            .environment(delegate.themeManager)
            .environment(carPlayState)

        let hostingVC = UIHostingController(rootView: dashboardView)
        hostingVC.view.backgroundColor = .black
        scene.carWindow.rootViewController = hostingVC
    }

    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }

    // MARK: - Private

    private func makeModeButton(controller: CPInterfaceController) -> CPBarButton {
        CPBarButton(title: "MODE") { [weak self] _ in
            guard let self else { return }
            self.showModeSelector(controller: controller)
        }
    }

    private func showModeSelector(controller: CPInterfaceController) {
        let template = ModeSelector.makeTemplate(currentMode: carPlayState.currentMode) { [weak self] mode in
            withAnimation(.easeInOut(duration: 0.35)) {
                self?.carPlayState.currentMode = mode
            }
            controller.popTemplate(animated: true)
        }
        controller.pushTemplate(template, animated: true)
    }
}
