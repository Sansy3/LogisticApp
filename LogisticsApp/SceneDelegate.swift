//
//  SceneDelegate.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//
import UIKit
import SwiftUI
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            // Check if the user is signed in
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                // User is signed in, show the main app screen
                let tabBarController = UITabBarController()
                
                // Cargo List View Controller
                let cargoListVC = CargoListViewController()
                if let truckIcon = UIImage(named: "truck1") {
                    let resizedTruckIcon = truckIcon.resized(to: CGSize(width: 25, height: 25))
                    cargoListVC.tabBarItem = UITabBarItem(title: "Cargos", image: resizedTruckIcon, tag: 0)
                }
                
                // Driver Dashboard View
                let driverDashboardVC = UIHostingController(rootView: DriverDashboardView())
                driverDashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "car.fill"), tag: 1)
                
                tabBarController.viewControllers = [cargoListVC, driverDashboardVC]
                window?.rootViewController = tabBarController
            } else {
                // User is not signed in, show the sign-in screen
                window?.rootViewController = SignInViewController()
            }
            
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
