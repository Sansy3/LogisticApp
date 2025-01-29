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
    
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.lastUpdate = Date()
    }
}//
//  DriverAnotations.swift
//  LogisticsApp
//
//  Created by beqa on 29.01.25.
//

