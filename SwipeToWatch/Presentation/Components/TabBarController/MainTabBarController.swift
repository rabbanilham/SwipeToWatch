//
//  MainTabBarController.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: - Private Properties -
    
    private var currentTabBarItem: UITabBarItem?
    
    // MARK: - View Controllers -
    
    private lazy var feedsViewController: FeedsViewController = {
        let viewController = FeedsViewController()
        viewController.tabBarItem = feedsTabBarItem
        
        return viewController
    }()
    
    private lazy var settingsViewController: SettingsViewController = {
        let viewController = SettingsViewController()
        viewController.tabBarItem = settingsTabBarItem
        
        return viewController
    }()
    
    // MARK: - Tab Bar Items -
    
    private lazy var feedsTabBarItem: UITabBarItem = UITabBarItem(
        title: "Feeds",
        image: UIImage(systemName: "list.and.film"),
        selectedImage: UIImage(systemName: "list.and.film")
    )
    
    private lazy var settingsTabBarItem: UITabBarItem = UITabBarItem(
        title: "Settings",
        image: UIImage(systemName: "gearshape"),
        selectedImage: UIImage(systemName: "gearshape.fill")
    )
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllers = [feedsViewController, settingsViewController].map { UINavigationController(rootViewController: $0) }
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        tabBar.tintColor = .systemPink
        tabBar.isTranslucent = false
        self.viewControllers = viewControllers
        self.currentTabBarItem = feedsTabBarItem
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == feedsTabBarItem, currentTabBarItem == item {
            Task {
                await feedsViewController.beginFeedsRefresh(usingRefreshControl: false)
                self.feedsViewController.scrollFeedsToTop()
            }
        }
        currentTabBarItem = item
    }
}
