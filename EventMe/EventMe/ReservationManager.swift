import Foundation

class ReservationManager {
    static let shared = ReservationManager()  // singleton instance
    private(set) var reserved: [Event] = []   // stored reserved events

    private init() {}

    /// Reserve the given event if not already reserved.
    func reserve(_ event: Event) {
        if !reserved.contains(event) {
            reserved.append(event)
        }
    }

    /// Check if the given event is already reserved.
    func isReserved(_ event: Event) -> Bool {
        reserved.contains(event)
    }
}
