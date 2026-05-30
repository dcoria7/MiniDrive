@preconcurrency import MapLibre
import SwiftUI
import CoreLocation

struct MapLibreView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    var heading: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MLNMapView {
        let mapView: MLNMapView

        if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
            mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        } else {
            mapView = MLNMapView(frame: .zero)
        }

        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = false
        mapView.showsUserLocation = false
        mapView.compassView.isHidden = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        guard coordinate.latitude != 0 || coordinate.longitude != 0 else { return }
        let camera = MLNMapCamera(
            lookingAtCenter: coordinate,
            altitude: 900,
            pitch: 0,
            heading: heading
        )
        mapView.setCamera(camera, withDuration: 0.5, animationTimingFunction: nil)
        context.coordinator.updateUserPin(on: mapView, at: coordinate)
    }

    @MainActor
    final class Coordinator: NSObject, MLNMapViewDelegate {
        private var userAnnotation: MLNPointAnnotation?

        func updateUserPin(on mapView: MLNMapView, at coordinate: CLLocationCoordinate2D) {
            if let existing = userAnnotation {
                existing.coordinate = coordinate
            } else {
                let pin = MLNPointAnnotation()
                pin.coordinate = coordinate
                mapView.addAnnotation(pin)
                userAnnotation = pin
            }
        }

        func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
            let id = "userPin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                view = MLNAnnotationView(reuseIdentifier: id)
                let dot = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
                dot.backgroundColor = UIColor(red: 0, green: 0.78, blue: 1, alpha: 1) // #00C8FF
                dot.layer.cornerRadius = 7
                dot.layer.borderWidth = 2
                dot.layer.borderColor = UIColor.white.cgColor
                view?.addSubview(dot)
                view?.frame = dot.frame
            }
            return view
        }
    }
}
