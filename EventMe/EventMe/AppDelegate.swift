import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NotificationManager.shared.requestAuthorization()
        return true
    }
}

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error { print("[Notifications] Error:", error) }
            print("[Notifications] Granted:", granted)
        }
        center.delegate = self
    }

    /// Schedule a local notification `minutesBefore` the event start time.
    /// This will **replace** any existing pending reminder for the same event.
    func scheduleReminder(for event: Event, minutesBefore: Int = 30) {
        let fireDate = event.date.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        guard fireDate > Date() else { return }

        let identifier = "event-\(event.id.uuidString)"
        // De-dupe any existing reminder for this event
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        let df = DateFormatter(); df.timeStyle = .short; df.dateStyle = .none
        content.body = "\(event.title) starts at \(df.string(from: event.date))."
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        comps.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        center.add(request) { if let error = $0 { print("[Notifications] schedule error:", error) } }
    }

    /// Cancel the pending reminder for a specific event, if any.
    func cancelReminder(for event: Event) {
        let identifier = "event-\(event.id.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel **all** pending reminders.
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }

    // Show while app is foregrounded
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Handle taps on the delivered notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.identifier
        // Our identifiers are formatted as "event-<UUID>"
        if id.hasPrefix("event-") {
            let uuidString = String(id.dropFirst("event-".count))
            if let uuid = UUID(uuidString: uuidString) {
                // Broadcast so SceneDelegate / coordinator can navigate to this event
                NotificationCenter.default.post(name: Notification.Name("openEventFromNotification"),
                                                object: nil,
                                                userInfo: ["eventId": uuid])
            }
        }
        completionHandler()
    }
}
