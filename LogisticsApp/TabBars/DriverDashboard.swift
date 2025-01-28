//
//  DriverDashboard.swift
//  LogisticsApp
//
//  Created by beqa on 28.01.25.
//

import UIKit

class DriverTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shipmentsVC = UINavigationController(rootViewController: MyShipmentsViewController())
        shipmentsVC.tabBarItem = UITabBarItem(title: "My Shipments", image: UIImage(systemName: "tray.full"), tag: 0)

        let mapVC = UINavigationController(rootViewController: MapVC())
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        
        let accountVC = UINavigationController(rootViewController: AccountViewController())
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle"), tag: 2)
        
        viewControllers = [shipmentsVC, mapVC, accountVC]
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor]
        gradient.frame = tabBar.bounds
        tabBar.layer.insertSublayer(gradient, at: 0)
    }
}
