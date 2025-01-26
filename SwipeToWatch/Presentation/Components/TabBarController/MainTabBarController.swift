//
//  MainTabBarController.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        delegate = self
        
        let feedsViewController = FeedsViewController()
        feedsViewController.tabBarItem = UITabBarItem(
            title: "Feeds",
            image: UIImage(systemName: "list.and.film"),
            selectedImage: UIImage(systemName: "list.and.film")
        )
        
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        tabBar.tintColor = .systemPink
        tabBar.isTranslucent = false
        self.viewControllers = [feedsViewController, UINavigationController(rootViewController: settingsViewController)]
    }
}
