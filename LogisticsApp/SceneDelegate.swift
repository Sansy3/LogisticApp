//
//  SceneDelegate.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
           
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            let tabBarController = UITabBarController()
            
            // Create UIKit view controller for Cargo List
            let cargoListVC = CargoListViewController() // A UIKit-based view controller
            
            // Load custom Truck icon and resize it
            if let truckIcon = UIImage(named: "truck1") {
                let resizedTruckIcon = truckIcon.resized(to: CGSize(width: 25, height: 25)) // Resize to match the system icons
                cargoListVC.tabBarItem = UITabBarItem(title: "Cargos", image: resizedTruckIcon, tag: 0)
            }
            
            // Create SwiftUI view controller for Driver Dashboard
            let driverDashboardVC = UIHostingController(rootView: DriverDashboardView()) // SwiftUI View
            driverDashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "car.fill"), tag: 1)
            
            tabBarController.viewControllers = [cargoListVC, driverDashboardVC]
            
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
