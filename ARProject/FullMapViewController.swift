//
//  FullMapViewController.swift
//  ARProject
//
//  Created by Van Luu on 2019-03-03.
//  Copyright © 2019 Van Luu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FullMapViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var searchBarMap: UISearchBar!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000

    @IBOutlet weak var fullMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        
        searchBarMap.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func setupLocationManger() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        
    }
    
    func centerViewOnUserLocation () {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            fullMapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManger()
            checkLocationAuthorization()
        } else {
            //show alert set up error handling after
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            fullMapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            //show alert to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //sent alert
            break
        case .authorizedAlways:
            break
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarMap.resignFirstResponder()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBarMap.text!) {
            (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                let placemark = placemarks?.first
                let annotation = MKPointAnnotation()
                annotation.coordinate = (placemark?.location?.coordinate)!
                
                annotation.title = self.searchBarMap.text!
                
                let span = MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                
                self.fullMapView.setRegion(region, animated: true)
                
                self.fullMapView.addAnnotation(annotation)
                self.fullMapView.selectAnnotation(annotation, animated: true)
                
            } else {
                print(error?.localizedDescription ?? "error")
            }
        }
        print("searching...\(searchBarMap.text!)")
        
    }
    

}

extension FullMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        fullMapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
