import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabBarAppearance()
        setupViewControllers()
    }
    
    private func setupTabBarAppearance() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tabBar.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.insertSubview(blurView, at: 0)
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradient.frame = tabBar.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        tabBar.layer.insertSublayer(gradient, at: 0)
        
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = true
        tabBar.itemPositioning = .centered
        tabBar.itemSpacing = 20
        tabBar.isTranslucent = true
    }
    
    private func setupViewControllers() {
        let loadboardVC = UINavigationController(rootViewController: LoadboardViewController())
        loadboardVC.tabBarItem = UITabBarItem(title: "Loadboard", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)

        let shipmentsVC = UINavigationController(rootViewController: MyShipmentsViewController())
        shipmentsVC.tabBarItem = UITabBarItem(title: "My Shipments", image: UIImage(systemName: "tray.full"), tag: 1)

        let trucksVC = UINavigationController(rootViewController: DriversViewController())
        trucksVC.tabBarItem = UITabBarItem(title: "My Drivers", image: UIImage(systemName: "car"), tag: 2)

        let mapVC = UINavigationController(rootViewController: MapVC())
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 3)

        let accountVC = UINavigationController(rootViewController: ProfileViewController())
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle"), tag: 4)

        viewControllers = [loadboardVC, shipmentsVC, trucksVC, mapVC, accountVC]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        
        // Get only UITabBarButton items
        let tabBarButtons = tabBar.subviews.filter { $0 is UIControl }
        
        // Ensure index is valid
        guard index < tabBarButtons.count else { return }
        
        let tabBarItemView = tabBarButtons[index]

        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.3, 0.9, 1.1, 1.0] // Bounce effect
        bounceAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 1] // Timings for each scale value
        bounceAnimation.duration = 0.4 // Duration of the bounce
        bounceAnimation.calculationMode = .cubic
        
        tabBarItemView.layer.add(bounceAnimation, forKey: "bounce")
    }



}
