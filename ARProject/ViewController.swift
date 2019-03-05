//
//  ViewController.swift
//  ARProject
//
//  Created by Van Luu on 2019-03-02.
//  Copyright © 2019 Van Luu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit
import CoreLocation


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var count: UILabel!
    var timer = Timer()
    var counter = 0
    var updateInfoLabelTimer: Timer?
    struct coordinate {
        var x = Double()
        var y = Double()
        var z = Double()
    }
    var myBase : SCNVector3!
    var friendBase : SCNVector3!
    
    
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()

        sceneView.delegate = self

        sceneView.showsStatistics = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        scheduledTimerWithTimeInterval()
        
        let button = UIButton(frame: CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 100, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Current Location", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(addCurrentLocation(sender:)), for: .touchUpInside)
        
        let button2 = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 100, width: 100, height: 50))
        button2.backgroundColor = .blue
        button2.setTitle("Friend Location", for: .normal)
        button2.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12)
        button2.addTarget(self, action: #selector(addFriendLocation(sender:)), for: .touchUpInside)
        
        let button3 = UIButton(frame: CGRect(x: 0, y: self.view.frame.width - 50, width: 100, height: 50))
        button3.backgroundColor = UIColor.blue
        button3.setTitle("Go", for: .normal)
        button3.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12)
        button3.addTarget(self, action: #selector(addLineFromGo(sender:)), for: .touchUpInside)
        
        self.view.addSubview(button)
        self.view.addSubview(button2)
        self.view.addSubview(button3)
        
        

    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCoordinates), userInfo: nil, repeats: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse{
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    //                    let currentLocation = locationManager.location
                    //                    long.text = String(describing: currentLocation?.coordinate.longitude)
                    //                    lat.text = String(describing: currentLocation?.coordinate.latitude)
                    //                    counter += 1
                    //                    count.text = String(describing: counter)
                }
            }
        }
    }
    
    // Uses Map
    @objc func updateCoordinates(){
        //        let currentLocation = locationManager.location
        //        long.text = String(describing: currentLocation?.coordinate.longitude)
        //        lat.text = String(describing: currentLocation?.coordinate.longitude)
        //        counter += 1
        //        print(counter)
        //        count.text = String(describing: counter)
    }
    
    // Uses AR
    func getCameraCoordinate(sceneview: ARSCNView) -> coordinate{
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = coordinate()
        cc.x = Double(cameraCoordinates.translation.x)
        cc.y = Double(cameraCoordinates.translation.y)
        cc.z = Double(cameraCoordinates.translation.z)
        
        return cc
    }
    
    
    @objc func addCurrentLocation(sender: UIButton!) {
        let alert = UIAlertController(title: "Marked", message: "Your location has been added to the map", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        let pink = UIColor(red: 255.0 / 255.0, green: 20.0 / 255.0, blue: 147.0 / 255.0, alpha: 0.8)
        
        let arrow = SCNNode(geometry: SCNPyramid(width: 0.5, height: 0.5, length: 0.5))
        let cc  = getCameraCoordinate(sceneview: sceneView)
        arrow.position = SCNVector3(cc.x,cc.y+0.7,cc.z-0.1)
        arrow.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        arrow.geometry!.firstMaterial?.diffuse.contents  = pink
        
        let base = SCNNode(geometry: SCNBox(width: 0.3, height: 0.4, length: 0.3, chamferRadius: 0))
        base.position = SCNVector3(cc.x,cc.y+1.05,cc.z-0.1)
        base.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        base.geometry!.firstMaterial?.diffuse.contents  = pink
        
        let base2 = SCNNode(geometry: SCNBox(width: 0.3, height: 0.1, length: 0.3, chamferRadius: 0))
        base2.position = SCNVector3(cc.x,cc.y+0.0775,cc.z-0.1)
        base2.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        base2.geometry!.firstMaterial?.diffuse.contents  = pink
        myBase = base2.position
        
        sceneView.scene.rootNode.addChildNode(arrow)
        sceneView.scene.rootNode.addChildNode(base)
        sceneView.scene.rootNode.addChildNode(base2)
    }
    
    
    @objc func addFriendLocation(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Marked", message: "Your friend's location has been added to the map", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        let green = UIColor.green
        
        let arrow = SCNNode(geometry: SCNPyramid(width: 0.5, height: 0.5, length: 0.5))
        let cc  = getCameraCoordinate(sceneview: sceneView)
        arrow.position = SCNVector3(cc.x+10,cc.y+0.7,cc.z-0.1)
        arrow.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        arrow.geometry!.firstMaterial?.diffuse.contents  = green
        let base = SCNNode(geometry: SCNBox(width: 0.3, height: 0.4, length: 0.3, chamferRadius: 0))
        base.position = SCNVector3(cc.x+10,cc.y+1.05,cc.z-0.1)
        base.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        base.geometry!.firstMaterial?.diffuse.contents  = green
        
        let base2 = SCNNode(geometry: SCNBox(width: 0.3, height: 0.1, length: 0.3, chamferRadius: 0))
        base2.position = SCNVector3(cc.x+10,cc.y+0.0775,cc.z-0.1)
        base2.pivot = SCNMatrix4MakeRotation(3.14,1,0,0)
        base2.geometry!.firstMaterial?.diffuse.contents  = green
        
        friendBase = base2.position
        
        
        
        
        sceneView.scene.rootNode.addChildNode(arrow)
        sceneView.scene.rootNode.addChildNode(base)
        sceneView.scene.rootNode.addChildNode(base2)
        
        
        
    }
    
    @objc func addLineFromGo(sender: UIButton!) {
        let line = SCNGeometry.line(from: myBase, to: friendBase)
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices : [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    
    func locationOnEarth( lat:Double, long:Double, currentLatitude:Double, currentLongitude:Double) -> coordinate{
        
        let lat = 42.292005
        let long = -83.716203
        
        let xOfInput = 6371000.0 * cos(lat) * cos(long)
        let yOfInput = 6371000.0 * cos(lat) * sin(long)
        let zOfInput = 6371000.0 * sin(lat)
        
        let currentLong = currentLongitude
        let currentLat = currentLatitude
        
        let xOfCurrent = 6371000.0 * cos(currentLat) * cos(currentLong)
        let yOfCurrent = 6371000.0 * cos(currentLat) * sin(currentLong)
        let zOfCurrent =  6371000.0 * sin(currentLat)
        
        let xFromCurrentToInput = xOfInput - xOfCurrent
        let zFromCurrentToInput = zOfInput - zOfCurrent
        let yFromCurrentToInput = yOfInput - yOfCurrent
        
        var loc = coordinate()
        loc.z = zFromCurrentToInput
        loc.y = yFromCurrentToInput
        loc.x = xFromCurrentToInput
        return loc
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        glLineWidth(20.0)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //MARK: - Set Up Core Location
    
    func setupLocationManger() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        
    }
    
    func centerViewOnUserLocation () {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
            mapView.showsUserLocation = true
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
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorization()
//    }
    
}
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
