import SwiftUI
import FirebaseFirestore
import MapKit

struct DetailLoadView: View {
    @Environment(\.presentationMode) var presentationMode
    let loadItem: LoadItem

    @State private var originCoordinate: CLLocationCoordinate2D?
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var distanceInMiles: String?
    @State private var isLoading = true
    @State private var selectedDriver: Driver?
    @State private var drivers: [Driver] = []
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Fetching coordinates...")
                        .padding()
                } else if let originCoordinate = originCoordinate, let destinationCoordinate = destinationCoordinate {
                    headerSection
                    distanceSection
                    detailSection
                    MapView(origin: originCoordinate, destination: destinationCoordinate)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    Text("Unable to fetch coordinates.")
                        .foregroundColor(.red)
                        .font(.headline)
                }

                driverSelectionSection
                assignDriverButton
                backButton
            }
            .padding()
            .onAppear {
                fetchCoordinates()
                fetchDrivers()
            }
        }
        .navigationBarTitle("Load Details", displayMode: .inline)
    }

    // MARK: - UI Components

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Load Details")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            Text("Route: \(loadItem.origin) → \(loadItem.destination)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var distanceSection: some View {
        VStack(spacing: 12) {
            Text("Distance: \(distanceInMiles ?? "--") miles")
                .font(.headline)
                .padding(.vertical)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                .padding(.horizontal)
        }
    }

    private var detailSection: some View {
        VStack(spacing: 12) {
            detailRow(title: "Status", value: loadItem.status)
            detailRow(title: "Weight", value: String(format: "%.2f lbs", loadItem.weight))
            detailRow(title: "Pickup Date", value: loadItem.pickupDate)
            detailRow(title: "Delivery Date", value: loadItem.deliveryDate)
            detailRow(title: "Truck Type", value: loadItem.truckType)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.headline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var driverSelectionSection: some View {
        VStack(spacing: 15) {
            Text("Select a Driver")
                .font(.headline)
                .padding(.top)

            if drivers.isEmpty {
                Text("No drivers available")
                    .foregroundColor(.red)
                    .font(.subheadline)
            } else {
                ForEach(drivers, id: \.id) { driver in
                    Button(action: {
                        self.selectedDriver = driver
                    }) {
                        Text("\(driver.firstName) \(driver.lastName)")
                            .padding()
                            .background(self.selectedDriver?.id == driver.id ? Color.green : Color.white)
                            .foregroundColor(self.selectedDriver?.id == driver.id ? .white : .black)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding(.bottom, 5)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var assignDriverButton: some View {
        Button(action: {
            if let driver = selectedDriver {
                assignDriverToLoad(driverId: driver.id, loadId: loadItem.id)
            }
        }) {
            Text("Assign Driver")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal)
        }
        .padding(.top)
        .disabled(selectedDriver == nil)
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Back")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }

    // MARK: - Fetch Coordinates using Geocoding
    private func fetchCoordinates() {
        isLoading = true
        let group = DispatchGroup()

        var resolvedOrigin: CLLocationCoordinate2D?
        var resolvedDestination: CLLocationCoordinate2D?

        group.enter()
        geocodeCity(loadItem.origin) { coordinate in
            resolvedOrigin = coordinate
            group.leave()
        }

        group.enter()
        geocodeCity(loadItem.destination) { coordinate in
            resolvedDestination = coordinate
            group.leave()
        }

        group.notify(queue: .main) {
            self.originCoordinate = resolvedOrigin
            self.destinationCoordinate = resolvedDestination
            if let origin = resolvedOrigin, let destination = resolvedDestination {
                self.distanceInMiles = calculateDistance(from: origin, to: destination)
            }
            self.isLoading = false
        }
    }

    private func geocodeCity(_ city: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }

    private func calculateDistance(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> String {
        let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distanceInMeters = originLocation.distance(from: destinationLocation)
        let distanceInMiles = distanceInMeters * 0.000621371
        return String(format: "%.2f", distanceInMiles)
    }

    // MARK: - Fetch Drivers from FirebaseManager
    private func fetchDrivers() {
        FirebaseManager.shared.listenToDrivers { result in
            switch result {
            case .success(let fetchedDrivers):
                self.drivers = fetchedDrivers
            case .failure(let error):
                self.errorMessage = "Error fetching drivers: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Assign Driver to Load
    private func assignDriverToLoad(driverId: String, loadId: String) {
        FirebaseManager.shared.addLoadToFirestore(loadItem: loadItem) { success in
            if success {
                // If load is successfully added, now assign the driver
                FirebaseManager.shared.assignDriverToLoad(loadId: loadId, driverId: driverId)
                presentationMode.wrappedValue.dismiss()  // Close the details view after assignment
            } else {
                // Handle the error, display an alert, or notify the user that the load couldn't be added
                errorMessage = "Error adding load to Firestore"
            }
        }
    }
}
