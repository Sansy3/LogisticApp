//
//  Model.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//

import Foundation

struct Cargo {
    var id: String
    var description: String
    var status: String
    var location: String
    var assignedDriver: String?
}

class CargoService {
    func getAllCargos() -> [Cargo] {
        // Placeholder data, typically fetched from Firebase or Gmail API
        return [
            Cargo(id: "1", description: "Cargo 1", status: "In Transit", location: "New York", assignedDriver: "Driver A"),
            Cargo(id: "2", description: "Cargo 2", status: "Delivered", location: "Chicago", assignedDriver: "Driver B")
        ]
    }
}
