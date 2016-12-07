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
    var locations = [Place]()
    var journey = [CLLocation]()
    var currentLocation : CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocation()
        
        Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?mode=walking&origin=40.775535,-73.961310&destination=40.729612,-73.988141&waypoints=via:40.729324,-73.981329&key=AIzaSyBrQyRpA3v1gZCznfUvcjSZFG5r_KnrnVs").responseJSON { response in
            if let JSON = response.result.value {
                let r = JSON as! NSDictionary
                for route in r["routes"] as! [NSDictionary] {
                    for leg in route["legs"] as! [NSDictionary] {
                        for step in leg["steps"] as! [NSDictionary] {
                            let end_loc = step["end_location"] as! NSDictionary
                            self.journey.append(CLLocation(latitude: end_loc["lat"] as! CLLocationDegrees,
                                                           longitude: end_loc["lng"] as! CLLocationDegrees))
                        }
                    }
                }
            }
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func showLocations() {
        _mapView.addAnnotations(locations)
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
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        currentLocation = lastLocation
        
        let accuracy:CLLocationAccuracy = lastLocation.horizontalAccuracy
        if(accuracy < 100.0) {
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.14 / 10, 0.14 / 10);
            let region:MKCoordinateRegion = MKCoordinateRegionMake(lastLocation.coordinate,span)
            self._mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self._mapView.showsUserLocation = true
    }
}

//MARK:
extension ViewController: MKMapViewDelegate {
    
    /*
    @IBAction func addLoctionAction() {
        if (currentLocation != nil) {
            let place = Place(_location: currentLocation!, _reference: "_reference", _placeName: "Nio Nguyen's home", _address: "_address", _phoneNumber: "_phoneNumber", _website: "_website")
            locations.append(place)
        }
        showLocations()
    }
    */
    
    @IBAction func cameraAction () {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let flipsideViewController = storyBoard.instantiateViewController(withIdentifier: "FlipsideViewController") as! FlipsideViewController
        flipsideViewController.locations = locations
        flipsideViewController.userLocation = _mapView.userLocation
        self.present(flipsideViewController, animated:true, completion:nil)
    }
}
