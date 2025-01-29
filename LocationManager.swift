import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager
    private var firestore: Firestore
    private var locationUpdateTimer: Timer?
    private let updateInterval: TimeInterval = 30 // Update every 30 seconds
    
    private override init() {
        locationManager = CLLocationManager()
        firestore = Firestore.firestore()
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 50 // Minimum distance (meters) before triggering update
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
    }
    
    func startTracking() {
        requestLocationPermissions()
        startLocationUpdates()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
    }
    
    private func requestLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func startLocationUpdates() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            startUpdateTimer()
        }
    }
    
    private func startUpdateTimer() {
        locationUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.uploadLastLocation()
        }
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
            "accuracy": location.horizontalAccuracy
        ]
        
        firestore.collection("locations")
            .document(userId)
            .setData(locationData, merge: true) { [weak self] error in
                if let error = error {
                    self?.handleError(error)
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
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        case .denied, .restricted:
            handleError(AppError.locationPermissionDenied)
        case .notDetermined:
            requestLocationPermissions()
        @unknown default:
            break
        }
    }
}//
//  LocationManager.swift
//  LogisticsApp
//
//  Created by beqa on 29.01.25.
//

