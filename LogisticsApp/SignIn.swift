import UIKit
import SwiftUI
import GoogleSignIn

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signInButton = GIDSignInButton()
        signInButton.center = view.center
        view.addSubview(signInButton)

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "1095945358765-9p52r1h6dugaoor82mjv178d9vn64udt.apps.googleusercontent.com")
        
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }

    @objc func signInTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }

            if let result = result {
                let userId = result.user.userID
                let fullName = result.user.profile?.name
                let email = result.user.profile?.email

                print("User ID: \(userId ?? "Unknown")")
                print("Full Name: \(fullName ?? "Unknown")")
                print("Email: \(email ?? "Unknown")")
                
                // After successful sign-in, transition to the main app screen
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = self.createTabBarController()
                }
            }
        }
    }
    
    func createTabBarController() -> UITabBarController {
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
        
        return tabBarController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}
