//
//  ViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 10/25/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import UIKit
import Pathfinder

class ViewController: UIViewController {
  let directionsUrlBase = "https://maps.googleapis.com/maps/api/directions/json?"
  let pathfinderAppId = "9c4166bb-9535-49e1-8844-1904a0b1f45b"
  let userCredentials = "abc"

  var vehicle: Vehicle!

  let interfaceManager = GITInterfaceManager()
  let locationManager = CLLocationManager()

  var drawnPath: GMSPolyline?
  var markers: [GMSMarker]?

  @IBOutlet weak var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up Google Identity Toolkit
    GITClient.sharedInstance().delegate = self
    let signIn = GIDSignIn.sharedInstance()
    signIn.scopes = [ "https://www.googleapis.com/auth/plus.login" ]
    signIn.delegate = self
    signIn.signIn()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func getDirections(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D]) {
    var directionsUrl = "\(directionsUrlBase)origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)"
    if !waypoints.isEmpty {
      directionsUrl += "&waypoints=optimize:true" + waypoints.map { (c: CLLocationCoordinate2D) -> String in "|\(c.latitude),\(c.longitude)" }.joinWithSeparator("")
    }
    let directionsNSUrl = NSURL(string: directionsUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    print("Requesting directions from \(directionsNSUrl)")
    dispatch_async(dispatch_get_main_queue()) {
      let directionsData = NSData(contentsOfURL: directionsNSUrl!)
      do {
        let response = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! [NSObject:AnyObject]
        let route = (response["routes"] as! [[NSObject:AnyObject]])[0]
        let overviewPolyline = route["overview_polyline"] as! [NSObject:AnyObject]
        self.drawPath(GMSPath(fromEncodedPath: overviewPolyline["points"] as! String))
      } catch {
        print("Unable to parse directions response from Google Maps: \(error)")
      }
    }
  }

  func drawPath(path: GMSPath) {
    drawnPath?.map = nil
    drawnPath = GMSPolyline(path: path)
    drawnPath?.map = mapView
    drawnPath?.strokeWidth = 4
  }

  func drawMarker(coordinate: CLLocationCoordinate2D, color: UIColor) -> GMSMarker {
    let marker = GMSMarker(position: coordinate)
    marker.map = mapView
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.icon = GMSMarker.markerImageWithColor(color)
    return marker
  }

  func randomColor() -> UIColor {
    let randomRed:CGFloat = CGFloat(drand48())
    let randomGreen:CGFloat = CGFloat(drand48())
    let randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
  }

  func afterSignIn() {
    // Set up Pathfinder
    vehicle = Pathfinder(applicationIdentifier: pathfinderAppId, userCredentials: userCredentials).defaultCluster().createVehicle(["chimney": 3])
    vehicle.delegate = self
    vehicle.connect()

    // Set up Google Maps
    mapView.delegate = self
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)

    // Request device location
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("ViewController is now authorized to view location.")
    if status == CLAuthorizationStatus.AuthorizedAlways {
      mapView.myLocationEnabled = true
      vehicle.connect()
    }
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("ViewController received updated location")
  }
  
}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if !mapView.settings.myLocationButton {
      let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
      mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
      mapView.settings.myLocationButton = true
    }
  }
  
}

// Mark: - VehicleDelegate
extension ViewController: VehicleDelegate {

  func wasRouted(route: Route, vehicle: Vehicle) {
    print("Vehicle delegate received updated route")
    var locations = route.coordinates()
    let startLocation = locations.removeFirst()
    let endLocation = locations.removeLast()
    getDirections(startLocation, end: endLocation, waypoints: locations)
    markers?.forEach { (m: GMSMarker) -> Void in m.map = nil }
    markers = [GMSMarker]()
    route.commodities().forEach { (commodity: Commodity) -> Void in
      let color = randomColor()
      markers?.append(drawMarker(commodity.start, color: color))
      markers?.append(drawMarker(commodity.destination, color: color))
    }
  }

  func performedRouteAction(action: RouteAction, vehicle: Vehicle) {
    print("Vehicle delegate notified of performed route action: \(action)")
  }

  func didComeOnline(vehicle: Vehicle) {
    print("Vehicle delegate notified of online vehicle")
  }

  func didGoOffline(vehicle: Vehicle) {
    print("Vehicle delegate notified of offline vehicle")
  }
}

// MARK: - GIDSignInDelegate
extension ViewController: GIDSignInDelegate {

  func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
    print("GID did sign in for user \(user) with authentication \(user.authentication)")
    afterSignIn()
  }
}

// MARK: - GITClientDelegate
extension ViewController: GITClientDelegate {

  func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
    print("GIT finished sign in and returned token \(token) for account \(account) with error \(error)")
    afterSignIn()
  }
}