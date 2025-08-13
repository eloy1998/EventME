//
//  ViewController.swift
//  EventMe
//
//  Created by Eloy Beaucejour on 8/7/25.
//

import UIKit

/// Root controller that wires up the app’s three main areas and surfaces the
/// optional features (search in Events, reserve+notifications in Detail, favorites in Profile,
/// dark mode toggle in Profile).
class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    private func configureTabBar() {
        // Events List tab (has UISearchController inside EventListViewController)
        let listVC = EventListViewController()
        listVC.title = "Events"
        let listNav = UINavigationController(rootViewController: listVC)
        listNav.navigationBar.prefersLargeTitles = true
        listNav.tabBarItem = UITabBarItem(title: "Events", image: UIImage(systemName: "list.bullet"), tag: 0)

        // Calendar tab (pushes to EventDetail where Reserve triggers notifications)
        let calVC = CalendarViewController()
        calVC.title = "Calendar"
        let calNav = UINavigationController(rootViewController: calVC)
        calNav.navigationBar.prefersLargeTitles = true
        calNav.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 1)

        // Profile tab (shows Saved + Dark Mode toggle)
        let profileVC = ProfileViewController()
        profileVC.title = "Profile"
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.navigationBar.prefersLargeTitles = true
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

        viewControllers = [listNav, calNav, profileNav]
        selectedIndex = 0
    }
}
