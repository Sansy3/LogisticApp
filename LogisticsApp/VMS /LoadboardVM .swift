import SwiftUI
import CoreLocation

class LoadboardViewModel {
    var loadItems: [LoadItem] = [] {
        didSet {
            reloadData?()
        }
    }
    var reloadData: (() -> Void)?

    func loadDummyData() {
        loadItems = [
            LoadItem(
                company: "Scholten's Equipment Inc",
                origin: "Lynden, WA (292)",
                destination: "Gillette, WY (345)",
                distance: "1,146 mi",
                price: "$1,100",
                time: "4 hr 16 min",
                originCoordinate: CLLocationCoordinate2D(latitude: 48.9970, longitude: -122.4560), // Lynden, WA
                destinationCoordinate: CLLocationCoordinate2D(latitude: 44.2900, longitude: -105.4990) // Gillette, WY
            ),
            LoadItem(
                company: "ABC Logistics",
                origin: "Seattle, WA",
                destination: "Portland, OR",
                distance: "180 mi",
                price: "$350",
                time: "2 hr",
                originCoordinate: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321), // Seattle, WA
                destinationCoordinate: CLLocationCoordinate2D(latitude: 45.5051, longitude: -122.6750) // Portland, OR
            ),
            LoadItem(
                company: "XYZ Transport",
                origin: "Chicago, IL",
                destination: "Denver, CO",
                distance: "1,000 mi",
                price: "$950",
                time: "10 hr",
                originCoordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), // Chicago, IL
                destinationCoordinate: CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903) // Denver, CO
            )
        ]
    }
}
