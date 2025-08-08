//
//  ViewController.swift
//  EventMe
//
//  Created by Eloy Beaucejour on 8/7/25.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    private func configureTabBar() {
        // Events List tab
        let listVC = EventListViewController()
        listVC.title = "Events"
        let listNav = UINavigationController(rootViewController: listVC)
        listNav.tabBarItem.image = UIImage(systemName: "list.bullet")

        // Calendar tab
        let calVC = CalendarViewController()
        calVC.title = "Calendar"
        let calNav = UINavigationController(rootViewController: calVC)
        calNav.tabBarItem.image = UIImage(systemName: "calendar")

        // Profile tab
        let profileVC = ProfileViewController()
        profileVC.title = "Profile"
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem.image = UIImage(systemName: "person")

        // Assign view controllers to the tab bar
        viewControllers = [listNav, calNav, profileNav]
    }
}

