import Foundation

/// Core event model used across lists, detail, reservations, favorites, and notifications.
struct Event: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var host: String
    var locationName: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var imageName: String

    // Hash by stable identity so sets/dictionaries and favorites work reliably
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // Convenience: case/diacritic-insensitive title match for search
    func matchesTitle(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return true }
        return title.range(of: q, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }

    // A stable local notification identifier for this event
    var notificationIdentifier: String { "event-\(id.uuidString)" }

    // Compute the reminder fire date, returns nil if it would be in the past
    func reminderFireDate(minutesBefore: Int) -> Date? {
        let fire = date.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        return fire > Date() ? fire : nil
    }
}
