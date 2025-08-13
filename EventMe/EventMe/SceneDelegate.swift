
import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // --- Tabs ---
        let listVC = EventListViewController(); listVC.title = "Events"
        let calVC  = CalendarViewController();  calVC.title  = "Calendar"
        let profVC = ProfileViewController();   profVC.title = "Profile"

        let listNav = UINavigationController(rootViewController: listVC)
        let calNav  = UINavigationController(rootViewController: calVC)
        let profNav = UINavigationController(rootViewController: profVC)
        [listNav, calNav, profNav].forEach { $0.navigationBar.prefersLargeTitles = true }

        let tabBar = UITabBarController()
        tabBar.viewControllers = [listNav, calNav, profNav]
        if let items = tabBar.tabBar.items, items.count == 3 {
            items[0].image = UIImage(systemName: "list.bullet")
            items[1].image = UIImage(systemName: "calendar")
            items[2].image = UIImage(systemName: "person")
        }
        tabBar.selectedIndex = 0

        window?.rootViewController = tabBar
        applyTheme()
        window?.makeKeyAndVisible()

        // --- Dark Mode live updates ---
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.applyTheme()
        }

        // --- Local notifications permission (for "Reserve → reminder" feature) ---
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error { print("[Notifications] Error:", error) }
            print("[Notifications] Granted:", granted)
        }
    }

    private func applyTheme() {
        window?.overrideUserInterfaceStyle = ThemeManager.shared.isDarkMode ? .dark : .light
    }
}

// MARK: - Theme support
final class ThemeManager {
    static let shared = ThemeManager()
    private let key = "EventME.isDarkMode"

    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let themeChanged  = Notification.Name("themeChanged")
    static let eventsUpdated = Notification.Name("eventsUpdated")
}
