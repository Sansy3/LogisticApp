import SwiftUI
import MapKit
import CoreLocation

// MARK: - Load Item Model
struct LoadItem: Decodable {
    let id: String
    let origin: String
    let destination: String
    let status: String
    let weight: Double
    let deliveryDate: String
    let pickupDate: String
    let truckType: String

    private enum CodingKeys: String, CodingKey {
        case id
        case origin = "Origin"
        case destination = "Destination"
        case status = "Status"
        case weight = "weight"
        case deliveryDate = "DeliveryDate"
        case pickupDate = "PicukDate" // Handle misspelled key
        case truckType = "TruckType"
    }
}
