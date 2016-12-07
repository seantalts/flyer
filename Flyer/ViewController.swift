//
//  ViewController.swift
//  Around Me-Swift
//
//  Created by Nio Nguyen on 6/5/15.
//  nio.huynguyen@gmail.com
//  Copyright (c) 2015 Nio Nguyen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class ViewController: UIViewController {
    var updatingLocation = false
    @IBOutlet weak var _mapView: MKMapView!
    var targets = [Place]()
    var journey = [Place]()
    var journeyIdx = -1
    var currentLocation : CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        self.populateJourney(url: "https://maps.googleapis.com/maps/api/directions/json?mode=walking&origin=40.729324,-73.981329&destination=40.729612,-73.988141&key=AIzaSyBrQyRpA3v1gZCznfUvcjSZFG5r_KnrnVs")
    }
    
    private func populateJourney(url: String) {
        self.journey = []
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value {
                let r = JSON as! NSDictionary
                for route in r["routes"] as! [NSDictionary] {
                    for leg in route["legs"] as! [NSDictionary] {
                        for step in leg["steps"] as! [NSDictionary] {
                            let end_loc = step["end_location"] as! NSDictionary
                            self.journey.append(Place(location: CLLocation(latitude: end_loc["lat"] as! CLLocationDegrees,
                                                                           longitude: end_loc["lng"] as! CLLocationDegrees),
                                                      text: "Next waypoint!"))
                        }
                    }
                }
            }
            self.activateNextLocation()
        }
    }

    func activateNextLocation() {
        print("Advancing to the next waypoint!")
        journeyIdx += 1
        if journeyIdx >= journey.count {
            let alert = UIAlertController(title: "This is it!",
                                          message: "You've reached the end of your journey. Good luck, and God speed.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Peace", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated:true, completion:nil)
        } else {
            let newPlace = journey[journeyIdx]
            _mapView.removeAnnotations(_mapView.annotations)
            _mapView.addAnnotation(newPlace)
            targets.removeAll()
            targets.append(newPlace)
        }
    }
}

//MARK:
extension ViewController: CLLocationManagerDelegate {
    func setupLocation() {
        let authStatus : CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            startLocationManager()
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            self._mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func currWaypoint() -> Place? {
        if journeyIdx >= 0 && journeyIdx < journey.count {
            return journey[journeyIdx]
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        currentLocation = lastLocation
        if let targetLocation = self.currWaypoint().map({wp in wp.location!}) {
            let distToCurr = currentLocation!.distance(from: targetLocation)
            print("Distance", distToCurr)
            // This distance appears to be in meters.
            if distToCurr < 5 {
                self.activateNextLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self._mapView.showsUserLocation = true
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK:
extension ViewController: MKMapViewDelegate {
    @IBAction func cameraAction () {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let flipsideViewController = storyBoard.instantiateViewController(withIdentifier: "FlipsideViewController") as! FlipsideViewController
        flipsideViewController.locations = targets
        flipsideViewController.userLocation = _mapView.userLocation
        self.present(flipsideViewController, animated:true, completion:nil)
    }
}
