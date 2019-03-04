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
            startTrackingUserLocation()
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
    
    func startTrackingUserLocation() {
        fullMapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCentreLocation(for: fullMapView)
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
    
    func getCentreLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        //find a way to implement live ETA that may hover over the AR Path
        
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else { return }
            
            for route in response.routes {
                self.fullMapView.addOverlay(route.polyline)
                self.fullMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true )
            }
        }
        
    }
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getCentreLocation(for: fullMapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        fullMapView.removeOverlay(fullMapView.overlays as! MKOverlay)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel()}
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {

        getDirections()
        //fixing button
    }
    


}

extension FullMapViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        fullMapView.setRegion(region, animated: true)
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

extension FullMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centre = getCentreLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previousLocation = self.previousLocation else { return }
        
        guard centre.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = centre
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(centre) { [weak self] (placemarks, error) in
            guard let self = self else {return }
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    func mapView(_ mapView: MKMapView, redererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        
        return renderer
    }
}
