import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager
    private var firestore: Firestore
    private var locationUpdateTimer: Timer?
    private let updateInterval: TimeInterval = 30
    private var locationListener: ListenerRegistration?
    
    // Add status tracking
    private var isCurrentlyTracking = false
    
    private override init() {
        locationManager = CLLocationManager()
        firestore = Firestore.firestore()
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 50
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func startTracking() {
        guard !isCurrentlyTracking else { return }
        
        // Verify Firebase Auth state
        guard let userId = Auth.auth().currentUser?.uid else {
            handleError(NSError(
                domain: "LocationManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated. Please log in."]
            ))
            return
        }
        
        // First verify the user's role
        let userDoc = firestore.collection("users").document(userId)
        userDoc.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            guard let userData = document?.data(),
                  let role = userData["role"] as? String,
                  role == "Driver" else {
                self.handleError(NSError(
                    domain: "LocationManager",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Only drivers can share location"]
                ))
                return
            }
            
            // Test location collection permissions
            self.testAndStartLocationUpdates(userId: userId)
        }
    }
    
    private func testAndStartLocationUpdates(userId: String) {
        // Test write permissions
        let testData: [String: Any] = [
            "testTimestamp": FieldValue.serverTimestamp()
        ]
        
        firestore.collection("locations").document(userId)
            .setData(testData, merge: true) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                // If we get here, permissions are good
                self.isCurrentlyTracking = true
                self.requestLocationPermissions()
                self.setupLocationListener(userId: userId)
                self.startLocationUpdates()
            }
    }
    
    private func startLocationUpdates() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            startUpdateTimer()
        }
    }
    
    private func setupLocationListener(userId: String) {
        locationListener?.remove()
        
        locationListener = firestore.collection("locations")
            .document(userId)
            .addSnapshotListener { [weak self] (document, error) in
                if let error = error {
                    self?.handleError(error)
                }
            }
    }
    
    private func startUpdateTimer() {
        locationUpdateTimer?.invalidate()
        
        locationUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.uploadLastLocation()
        }
        
        RunLoop.current.add(locationUpdateTimer!, forMode: .common)
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationListener?.remove()
        isCurrentlyTracking = false
    }
    
    private func requestLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func uploadLastLocation() {
        guard let location = locationManager.location,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": FieldValue.serverTimestamp(),
            "speed": location.speed >= 0 ? location.speed : 0,
            "heading": location.course,
            "accuracy": location.horizontalAccuracy,
            "userId": userId
        ]
        
        firestore.collection("locations")
            .document(userId)
            .setData(locationData, merge: true) { [weak self] error in
                if let error = error {
                    self?.handleError(error)
                    if (error as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                        self?.stopTracking()
                    }
                }
            }
    }
    
    private func handleError(_ error: Error) {
        print("Location Update Error: \(error.localizedDescription)")
        NotificationCenter.default.post(
            name: .locationUpdateError,
            object: nil,
            userInfo: ["error": error]
        )
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        NotificationCenter.default.post(
            name: .locationDidUpdate,
            object: nil,
            userInfo: ["location": location]
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            if isCurrentlyTracking {
                startLocationUpdates()
            }
        case .authorizedWhenInUse:
            requestLocationPermissions()
        case .denied, .restricted:
            handleError(NSError(
                domain: "LocationManager",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Location permissions denied"]
            ))
            stopTracking()
        case .notDetermined:
            requestLocationPermissions()
        @unknown default:
            break
        }
    }
}


