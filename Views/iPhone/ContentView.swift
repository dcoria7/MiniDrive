import SwiftUI
import CoreLocation

// MARK: - ContentView

struct ContentView: View {
    @Environment(LocationService.self) private var location

    var body: some View {
        switch location.authorizationStatus {
        case .notDetermined:
            PermissionRequestView()

        case .denied, .restricted:
            PermissionDeniedView()

        default:
            DashboardView()
        }
    }
}

// MARK: - PermissionRequestView

private struct PermissionRequestView: View {
    @Environment(LocationService.self) private var location

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            VStack(spacing: 32) {
                Image(systemName: "car.circle")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundStyle(Color(hex: "#E8FF00"))

                VStack(spacing: 10) {
                    Text("MINI DRIVE")
                        .font(.system(size: 24, weight: .thin, design: .monospaced))
                        .foregroundStyle(.white)
                        .kerning(8)

                    Text("Location access is required\nto show speed and direction.")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                Button("ALLOW LOCATION") {
                    location.requestPermissionAndStart()
                }
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .kerning(3)
                .foregroundStyle(Color(hex: "#0A0A0A"))
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color(hex: "#E8FF00"), in: Capsule())
            }
            .padding(40)
        }
    }
}

// MARK: - PermissionDeniedView

private struct PermissionDeniedView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "location.slash")
                    .font(.system(size: 60, weight: .thin))
                    .foregroundStyle(.white.opacity(0.4))

                Text("Location Disabled")
                    .font(.system(size: 18, weight: .light, design: .monospaced))
                    .foregroundStyle(.white)

                Text("Go to Settings → Privacy → Location\nand enable access for MiniDrive.")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .kerning(2)
                .foregroundStyle(Color(hex: "#E8FF00"))
            }
            .padding(40)
        }
    }
}
