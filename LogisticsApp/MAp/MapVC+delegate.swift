import MapKit
import UIKit

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is DriverAnnotation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: DriverAnnotationView.identifier,
            for: annotation
        ) as? DriverAnnotationView
        
        let calloutView = CustomCalloutView(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
        
        if let title = annotation.title, let subtitle = annotation.subtitle {
            calloutView.configure(with: title!, time: subtitle!)
        } else {
            calloutView.configure(with: "Unknown Driver", time: "No update time")
        }

        annotationView?.detailCalloutAccessoryView = calloutView
        
        return annotationView
    }
}
