import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    var drivers: [Driver] = DriverData.dummyDrivers
    private var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.delegate = self
        self.view.addSubview(mapView)

        if let firstDriver = drivers.first {
            let region = MKCoordinateRegion(
                center: firstDriver.location,
                span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
            )
            mapView.setRegion(region, animated: false)
        }

        addDriverAnnotations()
    }

    func addDriverAnnotations() {
        for driver in drivers {
            let annotation = MKPointAnnotation()
            annotation.coordinate = driver.location
            annotation.title = "\(driver.firstName) \(driver.lastName)"
            annotation.subtitle = driver.truckType
            mapView.addAnnotation(annotation)
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
