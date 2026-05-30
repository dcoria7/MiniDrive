import Observation

enum CarPlayMode: String, CaseIterable, Identifiable {
    case balanced   = "BALANCED"
    case mapFocus   = "MAP FOCUS"
    case speedFocus = "SPEED FOCUS"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .balanced:   return "Speed · Map · Compass"
        case .mapFocus:   return "Navigation mode"
        case .speedFocus: return "Highway mode"
        }
    }
}

@Observable
@MainActor
final class CarPlayState {
    var currentMode: CarPlayMode = .balanced
}
