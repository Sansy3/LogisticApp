import UIKit
import MapKit
import FirebaseFirestore

class MapVC: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let db = Firestore.firestore()
    private var driverAnnotations: [String: DriverAnnotation] = [:]
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.5]
        return gradient
    }()
    
    private lazy var centerUserLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        applyMapStyle()
        listenToDriverLocations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientOverlay.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Driver Locations"
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        view.addSubview(activityIndicator)
        view.addSubview(centerUserLocationButton)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            centerUserLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            centerUserLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            centerUserLocationButton.widthAnchor.constraint(equalToConstant: 50),
            centerUserLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add gradient overlay
        view.layer.insertSublayer(gradientOverlay, above: mapView.layer)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func applyMapStyle() {
        // Use a dark map style for a modern look
        if #available(iOS 13.0, *) {
            mapView.overrideUserInterfaceStyle = .dark
        }
        
        mapView.mapType = .mutedStandard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = false
        
        // Customize annotation appearance
        mapView.register(
            DriverAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: DriverAnnotationView.identifier
        )
    }
    
    // MARK: - Actions
    @objc private func centerMapOnUserLocation() {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
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
                
                snapshot?.documentChanges.forEach { change in
                    self.handleLocationChange(change)
                }
                
                self.updateMapRegion()
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
                if let annotation = self.driverAnnotations[driverId] {
                    if let annotationView = self.mapView.view(for: annotation) as? DriverAnnotationView {
                        annotationView.animateLocationUpdate(to: coordinate)
                    }
                    annotation.subtitle = self.formatLastUpdateTime()
                } else {
                    let annotation = DriverAnnotation(
                        coordinate: coordinate,
                        driverId: driverId,
                        title: name,
                        subtitle: self.formatLastUpdateTime()
                    )
                    self.driverAnnotations[driverId] = annotation
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
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
    
    private func updateMapRegion() {
        guard !driverAnnotations.isEmpty else { return }
        
        let annotations = Array(driverAnnotations.values)
        mapView.showAnnotations(annotations, animated: true)
    }
    
    private func formatLastUpdateTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Last updated: \(formatter.string(from: Date()))"
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
