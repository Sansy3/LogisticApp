import MapKit

class DriverAnnotation: MKPointAnnotation {
    let driverId: String
    var lastUpdate: Date
    
    init(coordinate: CLLocationCoordinate2D, driverId: String, title: String?, subtitle: String?) {
        self.driverId = driverId
        self.lastUpdate = Date()
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    func updateLocation(_ newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
        self.lastUpdate = Date()
    }
}
