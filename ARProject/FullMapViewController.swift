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
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.layer.cornerRadius = goButton.frame.size.height/2
        checkLocationServices()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        searchBarSearchButtonClicked(searchBarMap)
    }
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
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
     
     self.mapView.setRegion(region, animated: true)
     
     self.mapView.addAnnotation(annotation)
     self.mapView.selectAnnotation(annotation, animated: true)
     
     } else {
     print(error?.localizedDescription ?? "error")
     }
     }
     
     print("searching...\(searchBarMap.text!)")
     
     }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            //TODO: Inform user we don't have their current location
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //TODO: Handle error if needed
            guard let response = response else { return } //TODO: Show response not available in an alert
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections()
    }
}


extension FullMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


extension FullMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}


/*
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
 
 self.mapView.setRegion(region, animated: true)
 
 self.mapView.addAnnotation(annotation)
 self.mapView.selectAnnotation(annotation, animated: true)
 
 } else {
 print(error?.localizedDescription ?? "error")
 }
 }
 
 print("searching...\(searchBarMap.text!)")
 
 }
 */
