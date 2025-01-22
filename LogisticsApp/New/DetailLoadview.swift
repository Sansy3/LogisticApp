import SwiftUI
import MapKit

// MARK: - Detail View
struct DetailLoadView: View {
    @Environment(\.presentationMode) var presentationMode
    let loadItem: LoadItem

    @State private var originCoordinate: CLLocationCoordinate2D?
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var distanceInMiles: String?
    @State private var isLoading = true

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
                backButton
            }
            .padding()
            .onAppear {
                fetchCoordinates()
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
}
