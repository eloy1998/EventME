
import Foundation

/// Centralized store for reservations and favorites (saved events).
/// Posts `Notification.Name("eventsUpdated")` whenever state changes so UI can refresh.
final class ReservationManager {
    static let shared = ReservationManager()

    private(set) var reserved: [Event] = []   // upcoming reservations
    private(set) var saved: [Event] = []      // favorites (saved for later)

    private init() {}

    // MARK: - Reservations
    func reserve(_ event: Event) {
        if !reserved.contains(where: { $0.id == event.id }) {
            reserved.append(event)
            postUpdate()
        }
    }

    func isReserved(_ event: Event) -> Bool {
        reserved.contains(where: { $0.id == event.id })
    }

    func cancelReservation(_ event: Event) {
        if let idx = reserved.firstIndex(where: { $0.id == event.id }) {
            reserved.remove(at: idx)
            postUpdate()
        }
    }

    // MARK: - Favorites (Saved)
    func toggleSave(_ event: Event) {
        if let idx = saved.firstIndex(where: { $0.id == event.id }) {
            saved.remove(at: idx)
        } else {
            saved.append(event)
        }
        postUpdate()
    }

    func isSaved(_ event: Event) -> Bool {
        saved.contains(where: { $0.id == event.id })
    }

    func removeSaved(_ event: Event) {
        if let idx = saved.firstIndex(where: { $0.id == event.id }) {
            saved.remove(at: idx)
            postUpdate()
        }
    }

    // MARK: - Notification helper
    private func postUpdate() {
        NotificationCenter.default.post(name: Notification.Name("eventsUpdated"), object: nil)
    }
}
