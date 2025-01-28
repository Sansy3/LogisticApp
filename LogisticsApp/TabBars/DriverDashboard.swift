import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class DriverTabBarController: UITabBarController, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var firestore: Firestore!
    private var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firestore = Firestore.firestore()
        
        // Get the current user ID
        if let user = Auth.auth().currentUser {
            userId = user.uid
        }
        
        let shipmentsVC = UINavigationController(rootViewController: MyShipmentsViewController())
        shipmentsVC.tabBarItem = UITabBarItem(title: "My Shipments", image: UIImage(systemName: "tray.full"), tag: 0)

        let mapVC = UINavigationController(rootViewController: MapVC())
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        
        let accountVC = UINavigationController(rootViewController: AccountViewController())
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle"), tag: 2)
        
        viewControllers = [shipmentsVC, mapVC, accountVC]
        
        // Add gradient to tab bar
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor]
        gradient.frame = tabBar.bounds
        tabBar.layer.insertSublayer(gradient, at: 0)
        
        // Start location tracking
        startLocationTracking()
    }
    
    private func startLocationTracking() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Request location permissions
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate method for updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Save the current location
        currentLocation = newLocation
        
        // Upload location to Firestore
        uploadLocationToFirestore(location: newLocation)
    }
    
    // CLLocationManagerDelegate method for error handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    private func uploadLocationToFirestore(location: CLLocation) {
        guard let userId = userId else { return }
        
        // Upload location to Firestore under a "locations" collection
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Create or update the user's location document in Firestore
        firestore.collection("locations").document(userId).setData(locationData, merge: true) { error in
            if let error = error {
                print("Error uploading location: \(error.localizedDescription)")
            } else {
                print("Location successfully uploaded to Firestore.")
            }
        }
    }
    
    // When the driver stops the app, stop location tracking
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
}
