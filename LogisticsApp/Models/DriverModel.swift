import CoreLocation

struct Driver {
    let firstName: String
    let lastName: String
    let truckType: String
    let location: CLLocationCoordinate2D

}

class DriverData {
    static let dummyDrivers: [Driver] = [
        Driver(firstName: "John", lastName: "Doe", truckType: "Flatbed", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)), // San Francisco
        Driver(firstName: "Jane", lastName: "Smith", truckType: "Reefer", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)), // Los Angeles
        Driver(firstName: "Michael", lastName: "Johnson", truckType: "Box Truck", location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)), // New York
        Driver(firstName: "Sarah", lastName: "Brown", truckType: "Tanker", location: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298)) // Chicago
    ]
}
