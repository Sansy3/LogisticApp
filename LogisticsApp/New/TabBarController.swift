//
//  TabBarController.swift
//  LogisticsApp
//
//  Created by beqa on 21.01.25.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let loadboardVC = UINavigationController(rootViewController: LoadboardViewController())
        loadboardVC.tabBarItem = UITabBarItem(title: "Loadboard", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)
        loadboardVC.navigationBar.barTintColor = UIColor.systemBlue

        let shipmentsVC = UINavigationController(rootViewController: MyShipmentsViewController())
        shipmentsVC.tabBarItem = UITabBarItem(title: "My Shipments", image: UIImage(systemName: "tray.full"), tag: 1)

        let trucksVC = UINavigationController(rootViewController: MyDriversVC())
        trucksVC.tabBarItem = UITabBarItem(title: "My Drivers", image: UIImage(systemName: "car"), tag: 2)

        let mapVC = UINavigationController(rootViewController: MapVC())
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 3)

        let accountVC = UINavigationController(rootViewController: AccountViewController())
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle"), tag: 4)

        viewControllers = [loadboardVC, shipmentsVC, trucksVC, mapVC, accountVC]

        // Apply gradient background to the TabBar
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradient.frame = tabBar.bounds
        tabBar.layer.insertSublayer(gradient, at: 0)

    }
}
