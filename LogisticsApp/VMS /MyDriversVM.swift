//
//  MyDriversVM.swift
//  LogisticsApp
//
//  Created by beqa on 21.01.25.
//

import Foundation
import CoreLocation

class MyDriversViewModel {
    
    private(set) var drivers: [Driver] = []
    
    var reloadData: (() -> Void)?
    
    func loadDrivers() {
        self.drivers = DriverData.dummyDrivers
        reloadData?()
    }
    
    func addDriver(firstName: String, lastName: String, truckType: String, latitude: Double, longitude: Double) {
        let newDriver = Driver(firstName: firstName, lastName: lastName, truckType: truckType, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        self.drivers.append(newDriver)
        reloadData?() // Notify the view to reload
    }
}
