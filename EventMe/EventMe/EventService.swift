import Foundation

class EventService {
    static let shared = EventService()  // singleton instance
    private(set) var events: [Event] = []

    private init() {
        loadSampleEvents()
    }

    private func loadSampleEvents() {
        // Sample events; replace or extend with real data as needed
        events = [
            Event(
                id: UUID(),
                title: "Food Truck Festival",
                description: "Live music, street eats, and community vibes.",
                host: "City Plaza",
                locationName: "City Plaza",
                latitude: 37.7749,
                longitude: -122.4194,
                date: Date().addingTimeInterval(3600),  // 1 hour from now
                imageName: "foodtruck"
            ),
            Event(
                id: UUID(),
                title: "Pop-up Concert",
                description: "Indie bands performing live downtown.",
                host: "Music Co.",
                locationName: "Downtown Stage",
                latitude: 37.7793,
                longitude: -122.4182,
                date: Date().addingTimeInterval(7200),  // 2 hours from now
                imageName: "concert"
            )
        ]
    }

    // Add a new event and notify UI to refresh
    func add(_ event: Event) {
        events.append(event)
        NotificationCenter.default.post(name: Notification.Name("eventsUpdated"), object: nil)
    }

    // Convenience search used by EventListViewController
    func search(byTitle query: String) -> [Event] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return events }
        return events.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
    }

    // Helper to get events ordered by start time
    func sortedByDate() -> [Event] {
        events.sorted { $0.date < $1.date }
    }
}
