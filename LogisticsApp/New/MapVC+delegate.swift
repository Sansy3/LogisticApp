//
//  MapVC+delegate.swift
//  LogisticsApp
//
//  Created by beqa on 29.01.25.
//

import MapKit
import UIKit

extension MapVC: MKMapViewDelegate {
    private var annotationViewIdentifier: String { "DriverAnnotationView" } 
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is DriverAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewIdentifier
        ) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: annotationViewIdentifier
            )
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = UIColor.systemBlue // Explicitly use UIColor
            
            // Add a button to the callout
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? DriverAnnotation else { return }
        // Handle tap on driver annotation info button
        print("Tapped info button for driver: \(annotation.driverId)")
    }
}
