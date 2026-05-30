@preconcurrency import CarPlay

struct ModeSelector {
    static func makeTemplate(
        currentMode: CarPlayMode,
        onSelect: @escaping (CarPlayMode) -> Void
    ) -> CPListTemplate {
        let items: [CPListItem] = CarPlayMode.allCases.map { mode in
            let item = CPListItem(text: mode.rawValue, detailText: mode.subtitle)
            item.handler = { _, completion in
                completion()
                Task { @MainActor in onSelect(mode) }
            }
            return item
        }
        let section = CPListSection(items: items)
        return CPListTemplate(title: "DRIVE MODE", sections: [section])
    }
}
