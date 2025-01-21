import SwiftUI
import MapKit

struct MapView: UIViewControllerRepresentable {
    var origin: CLLocationCoordinate2D
    var destination: CLLocationCoordinate2D

    func makeUIViewController(context: Context) -> MKMapViewController {
        return MKMapViewController(origin: origin, destination: destination)
    }

    func updateUIViewController(_ uiViewController: MKMapViewController, context: Context) {
    }
}

class MKMapViewController: UIViewController, MKMapViewDelegate {
    var origin: CLLocationCoordinate2D
    var destination: CLLocationCoordinate2D

    private var mapView: MKMapView!

    init(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        self.origin = origin
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (origin.latitude + destination.latitude) / 2,
                                            longitude: (origin.longitude + destination.longitude) / 2),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        mapView.setRegion(region, animated: true)

        let originPin = MKPointAnnotation()
        originPin.coordinate = origin
        originPin.title = "Origin"
        mapView.addAnnotation(originPin)

        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = destination
        destinationPin.title = "Destination"
        mapView.addAnnotation(destinationPin)

        getDirections()
    }

    private func getDirections() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let route = response?.routes.first else { return }
            self?.mapView.addOverlay(route.polyline)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
