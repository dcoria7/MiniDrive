import CoreLocation
import Observation

// MARK: - LocationService

@Observable
@MainActor
final class LocationService: NSObject {

    // MARK: Observed

    private(set) var speedKmh: Double = 0
    private(set) var headingDegrees: Double = 0
    private(set) var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    private(set) var altitude: Double = 0
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var isActive: Bool = false

    // MARK: Private

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var smoothedSpeed: Double = 0
    @ObservationIgnored private let smoothingFactor: Double = 0.25

    // MARK: Init

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 2                // update every 2 meters
        manager.headingFilter = 1                 // update every 1 degree
    }

    // MARK: Public

    func requestPermissionAndStart() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdates()
        default:
            break
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isActive = false
    }

    // MARK: Private

    private func startUpdates() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        isActive = true
    }

    /// Exponential Moving Average to smooth GPS speed spikes
    private func smooth(_ newValue: Double, current: Double) -> Double {
        smoothingFactor * newValue + (1 - smoothingFactor) * current
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                startUpdates()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            let rawSpeed = max(0, location.speed)               // negative = invalid
            let rawKmh = rawSpeed * 3.6

            smoothedSpeed = smooth(rawKmh, current: smoothedSpeed)
            speedKmh = smoothedSpeed.rounded()

            coordinate = location.coordinate
            altitude = location.altitude
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            headingDegrees = newHeading.trueHeading >= 0
                ? newHeading.trueHeading
                : newHeading.magneticHeading
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        // In a production app, surface this error to the user
        print("[LocationService] Error: \(error.localizedDescription)")
    }
}

// MARK: - Heading helpers

extension Double {
    /// Returns cardinal direction string from heading degrees
    var cardinalDirection: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((self + 22.5) / 45.0) % 8
        return directions[index]
    }
}
