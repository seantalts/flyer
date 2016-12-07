import CoreLocation
import MapKit

class PlaceAnnotation : NSObject, MKAnnotation {
    var place:Place!
    init(_place: Place) {
        self.place = _place
    }
    
    @objc var coordinate: CLLocationCoordinate2D {
        return self.place!.location!.coordinate
    }
    
    var title: String! {
        return self.place!.placeName
    }
    
}
