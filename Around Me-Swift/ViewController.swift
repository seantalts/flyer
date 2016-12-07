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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    var updatingLocation = false
    @IBOutlet weak var _mapView: MKMapView!
    var locations = [Place]()
    var currentLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        if (currentLocation == nil) {
            randomLocation(lastLocation, number: 10)
        }
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
    
    func randomLocation(_ location:CLLocation, number:Int) {
        for _ in 1...number {
            let newLocation = CLLocation(latitude: location.coordinate.latitude + 0.005 * Double.random(min: -1.0, max: 1.0) , longitude: location.coordinate.longitude + 0.005 * Double.random(min: -1.0, max: 1.0))
            let place = Place(_location: newLocation, _reference: "_reference", _placeName: "Nio Nguyen's home", _address: "_address", _phoneNumber: "_phoneNumber", _website: "_website")
            locations.append(place)
        }
        showLocations()
    }

    @IBAction func addLoctionAction() {
        if (currentLocation != nil) {
            let place = Place(_location: currentLocation!, _reference: "_reference", _placeName: "Nio Nguyen's home", _address: "_address", _phoneNumber: "_phoneNumber", _website: "_website")
            locations.append(place)
        }
        showLocations()
    }
    
    func showLocations() {
        _mapView.addAnnotations(locations)
    }
    
    @IBAction func cameraAction () {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let flipsideViewController = storyBoard.instantiateViewController(withIdentifier: "FlipsideViewController") as! FlipsideViewController
        flipsideViewController.locations = locations
        flipsideViewController.userLocation = _mapView.userLocation
        self.present(flipsideViewController, animated:true, completion:nil)
    }
}

