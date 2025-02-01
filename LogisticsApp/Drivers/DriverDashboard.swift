import UIKit

class DriverTabBarController: UITabBarController {
    // MARK: - Properties
    private let locationManager = LocationManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
        startLocationTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopTracking()
    }
    
    // MARK: - Setup
    private func setupViewControllers() {
        viewControllers = [
            createNavigationController(
                for: DriverShipmentsViewController(),
                title: "My Shipments",
                image: "tray.full"
            ),
            createNavigationController(
                for: MapVC(),
                title: "Map",
                image: "map"
            ),
            createNavigationController(
                for: ProfileViewController(),
                title: "Account",
                image: "person.circle"
            )
        ]
    }
    
    private func createNavigationController(
        for rootViewController: UIViewController,
        title: String,
        image: String
    ) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: image)
        return navController
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func startLocationTracking() {
        locationManager.startTracking()
    }
}
