import UIKit
import FirebaseAuth
import MapKit
import FirebaseFirestore

class MapVC: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let db = Firestore.firestore()
    private var driverAnnotations: [String: DriverAnnotation] = [:]
    private var isDispatcher: Bool = false

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var showAllDriversButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showAllDrivers), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserRole()
        setupUI()
        setupMapView()
        listenToDriverLocations()
        mapView.register(DriverAnnotationView.self, forAnnotationViewWithReuseIdentifier: DriverAnnotationView.identifier)
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Driver Locations"
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        view.addSubview(activityIndicator)
        view.addSubview(showAllDriversButton)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            showAllDriversButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showAllDriversButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showAllDriversButton.widthAnchor.constraint(equalToConstant: 50),
            showAllDriversButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    // MARK: - Check Role
    private func checkUserRole() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error checking user role: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let role = document.get("role") as? String {
                self.isDispatcher = role == "Dispatcher"
                self.setupMapForUserRole()
            }
        }
    }
    
    private func setupMapForUserRole() {
        if isDispatcher {
            showAllDriversButton.isHidden = false
            listenToDriverLocations()
        } else {
            showAllDriversButton.isHidden = true
            listenToOwnLocation()
        }
    }

    // MARK: - Actions
    @objc private func showAllDrivers() {
        updateMapRegionForAllDrivers()
    }

    // MARK: - Driver Location Tracking
    private func listenToDriverLocations() {
        activityIndicator.startAnimating()
        
        db.collection("locations")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showError(message: error.localizedDescription)
                    return
                }
                
                // Process all changes
                snapshot?.documentChanges.forEach { change in
                    self.handleLocationChange(change)
                }
            }
    }
    
    private func listenToOwnLocation() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("locations").document(userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists,
               let latitude = snapshot.get("latitude") as? CLLocationDegrees,
               let longitude = snapshot.get("longitude") as? CLLocationDegrees {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.updateUserLocation(coordinate)
            }
        }
    }
    
    private func handleLocationChange(_ change: DocumentChange) {
        let document = change.document
        let driverId = document.documentID
        
        guard let latitude = document.get("latitude") as? CLLocationDegrees,
              let longitude = document.get("longitude") as? CLLocationDegrees else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        switch change.type {
        case .added, .modified:
            updateDriverLocation(driverId: driverId, coordinate: coordinate)
        case .removed:
            removeDriver(driverId: driverId)
        @unknown default:
            break
        }
    }
    
    private func updateDriverLocation(driverId: String, coordinate: CLLocationCoordinate2D) {
        fetchDriverName(driverId: driverId) { [weak self] name in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let subtitle = self.formatLastUpdateTime() // Get the subtitle (last updated time)
                
                if let annotation = self.driverAnnotations[driverId] {
                    annotation.updateLocation(coordinate)
                    annotation.subtitle = subtitle // Update the subtitle for existing annotation
                } else {
                    let annotation = DriverAnnotation(
                        coordinate: coordinate,
                        driverId: driverId,
                        title: name,
                        subtitle: subtitle // Pass the subtitle here
                    )
                    self.driverAnnotations[driverId] = annotation
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    private func formatLastUpdateTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Last updated: \(formatter.string(from: Date()))"
    }

    
    private func fetchDriverName(driverId: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(driverId).getDocument { document, error in
            if let error = error {
                print("Error fetching driver name: \(error.localizedDescription)")
                completion("Unknown Driver")
                return
            }
            
            guard let document = document,
                  document.exists,
                  let name = document.get("name") as? String else {
                completion("Unknown Driver")
                return
            }
            
            completion(name)
        }
    }
    
    private func removeDriver(driverId: String) {
        if let annotation = driverAnnotations[driverId] {
            mapView.removeAnnotation(annotation)
            driverAnnotations.removeValue(forKey: driverId)
        }
    }
    
    private func updateMapRegionForAllDrivers() {
        var coordinates: [CLLocationCoordinate2D] = []
        
        // Include all driver locations
        for annotation in driverAnnotations.values {
            coordinates.append(annotation.coordinate)
        }
        
        // Include user location if available
        if let userLocation = mapView.userLocation.location?.coordinate {
            coordinates.append(userLocation)
        }
        
        let rect = coordinates.reduce(MKMapRect.null) { rect, coordinate in
            let point = MKMapPoint(coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.union(pointRect)
        }
        
        let padding: Double = 1.2
        let paddedRect = rect.insetBy(dx: -rect.width * (padding - 1) / 2, dy: -rect.height * (padding - 1) / 2)
        
        mapView.setVisibleMapRect(paddedRect, animated: true)
    }

    private func updateUserLocation(_ coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your Location"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        // Optionally, center the map on the user location
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
