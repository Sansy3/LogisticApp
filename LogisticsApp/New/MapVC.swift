import UIKit
import MapKit
import FirebaseFirestore

class MapVC: UIViewController, MKMapViewDelegate {
    
    private var mapView: MKMapView!
    private var db = Firestore.firestore()
    private var driverAnnotations: [String: MKPointAnnotation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map view
        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        // Listen to all drivers' locations in Firestore
        listenToDriverLocations()
    }
    
    // Listen to the Firestore 'locations' collection
    func listenToDriverLocations() {
        db.collection("locations").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for driver locations: \(error.localizedDescription)")
                return
            }
            
            // Process each document (driver location)
            snapshot?.documentChanges.forEach { change in
                let document = change.document
                
                // Get the driver's ID and location data
                let driverId = document.documentID
                let latitude = document.get("latitude") as? CLLocationDegrees ?? 0.0
                let longitude = document.get("longitude") as? CLLocationDegrees ?? 0.0
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                // Update or add the annotation for this driver
                self.updateDriverAnnotation(driverId: driverId, coordinate: coordinate)
            }
            
            // After handling all the changes, update the map region to show all drivers
            self.updateMapRegion()
        }
    }
    
    // Update or add a driver's annotation on the map
    func updateDriverAnnotation(driverId: String, coordinate: CLLocationCoordinate2D) {
        if let existingAnnotation = driverAnnotations[driverId] {
            existingAnnotation.coordinate = coordinate
        } else {
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = coordinate
            newAnnotation.title = "Driver \(driverId)"  // You can modify this to include the driver's name
            mapView.addAnnotation(newAnnotation)
            driverAnnotations[driverId] = newAnnotation
        }
    }
    
    // Update map bounds when new annotations are added
    func updateMapRegion() {
        guard !driverAnnotations.isEmpty else { return }
        
        var minLat = 90.0
        var maxLat = -90.0
        var minLon = 180.0
        var maxLon = -180.0
        
        // Find the minimum and maximum latitudes and longitudes
        for annotation in driverAnnotations.values {
            let coordinate = annotation.coordinate
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        // Create a region that covers all the annotations
        let spanLat = maxLat - minLat
        let spanLon = maxLon - minLon
        let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2, longitude: (maxLon + minLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        let region = MKCoordinateRegion(center: center, span: span)
        
        // Set the region to show all drivers
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
    }
}
