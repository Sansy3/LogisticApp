import UIKit
import MapKit

class DriverAnnotationView: MKMarkerAnnotationView {
    static let identifier = "DriverAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStyle()
    }
    
    private func setupStyle() {
        glyphImage = UIImage(systemName: "car.fill")
        markerTintColor = .systemBlue
        glyphTintColor = .white
        animatesWhenAdded = true
        
        canShowCallout = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let bounceAnimation = CABasicAnimation(keyPath: "transform.scale")
        bounceAnimation.duration = 0.2
        bounceAnimation.fromValue = 0.8
        bounceAnimation.toValue = 1.0
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(bounceAnimation, forKey: "bounce")
    }
    
    func animateLocationUpdate(to newCoordinate: CLLocationCoordinate2D) {
        guard let driverAnnotation = annotation as? DriverAnnotation else { return }

        UIView.animate(withDuration: 0.3,
                      delay: 0,
                      usingSpringWithDamping: 0.7,
                      initialSpringVelocity: 0.7,
                      options: .curveEaseInOut) {
            driverAnnotation.updateLocation(newCoordinate)
        }
    }
}
