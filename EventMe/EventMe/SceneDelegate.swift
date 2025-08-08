import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let root = ViewController()                  // your UITabBarController subclass
        window?.rootViewController = root
        window?.makeKeyAndVisible()

        // Create view controllers for each tab
        let listVC = EventListViewController()
        listVC.title = "Events"
        let calVC = CalendarViewController()
        calVC.title = "Calendar"
        let profileVC = ProfileViewController()
        profileVC.title = "Profile"

        // Embed in navigation controllers
        let listNav = UINavigationController(rootViewController: listVC)
        let calNav = UINavigationController(rootViewController: calVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        // Configure tab bar
        let tabBar = UITabBarController()
        tabBar.viewControllers = [listNav, calNav, profileNav]
        tabBar.tabBar.items?[0].image = UIImage(systemName: "list.bullet")
        tabBar.tabBar.items?[1].image = UIImage(systemName: "calendar")
        tabBar.tabBar.items?[2].image = UIImage(systemName: "person")

        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
}
