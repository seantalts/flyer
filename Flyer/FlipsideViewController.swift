import UIKit
import MapKit
class FlipsideViewController: UIViewController, ARLocationDelegate, ARDelegate, ARMarkerDelegate, MarkerViewDelegate {
    
    var userLocation:MKUserLocation?
    var locations = [Place]()
    var geoLocationsArray = [ARGeoCoordinate]()
    var _arController:AugmentedRealityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (_arController == nil) {
            _arController = AugmentedRealityController(view: self.view, parentViewController: self, withDelgate: self)
            
            _arController!.minimumScaleFactor = 0.5
            _arController!.scaleViewsBasedOnDistance = true
            _arController!.rotateViewsBasedOnPerspective = true
            _arController!.debugMode = false
        }
        geoLocations()
    }

    func generateGeoLocations() {        
        for place in locations {
            let coordinate:ARGeoCoordinate = ARGeoCoordinate(location: place.location, locationTitle: place.placeName)
            coordinate.calibrate(usingOrigin: userLocation?.location)
            
            let markerView:MarkerView = MarkerView(_coordinate: coordinate, _delegate: self)
            coordinate.displayView = markerView
            
            _arController?.addCoordinate(coordinate)
            geoLocationsArray.append(coordinate)
        }
        
    }
    
    func locationClicked(_ coordinate:ARGeoCoordinate) {
    
    }
    
    func geoLocations() -> NSMutableArray{
        
        if(geoLocationsArray.count == 0) {
            generateGeoLocations()
        }
        return NSMutableArray(array: geoLocationsArray) ;

    }
    
    func locationClicked() {
    }
    
    func didUpdate(_ newHeading:CLHeading){
        
    }
    func didUpdate(_ newLocation:CLLocation){
        
    }
    func didUpdate(_ orientation:UIDeviceOrientation) {
        
    }
    
    func didTapMarker(_ coordinate:ARGeoCoordinate) {
        
    }
    
    func didTouchMarkerView(_ markerView:MarkerView) {
        
    }
    
    @IBAction func doneAction() {
        dismiss(animated: true, completion: nil)
    }
}
