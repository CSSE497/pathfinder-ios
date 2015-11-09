//
//  TransportViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import thepathfinder

class TransportViewController: UIViewController {
  let directionsUrlBase = "https://maps.googleapis.com/maps/api/directions/json?"
  let pathfinderAppId = "9c4166bb-9535-49e1-8844-1904a0b1f45b"
  let userCredentials = "abc"

  var transport: Transport!

  let interfaceManager = GITInterfaceManager()
  var locationManager = CLLocationManager()

  var drawnPath: GMSPolyline?
  var markers: [GMSMarker]?

  var didFindMyLocation = false

  var mapView: GMSMapView!

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
    let directionsNSUrl = NSURL(string: directionsUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
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
    print("Drawing marker at \(coordinate)")
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

  func setUp() {
    // Set up Pathfinder. Subscribe to the transport after the connection is confirmed.
    let cluster = Pathfinder(applicationIdentifier: pathfinderAppId, userCredentials: userCredentials).cluster()
    transport = cluster.createTransport(Transport.Status.Online, parameterCapacities: ["chimney": 3])
    transport.delegate = self
    transport.connect()

    // Set up Google Maps
    mapView.delegate = self
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)

    // Request device location
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
}

// MARK: - CLLocationManagerDelegate
extension TransportViewController: CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("ViewController is now authorized to view location.")
    if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
      mapView.myLocationEnabled = true
      transport.connect()
    }
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("ViewController received updated location")
  }

}

// MARK: - GMSMapViewDelegate
extension TransportViewController: GMSMapViewDelegate {

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if !didFindMyLocation {
      let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
      mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
      mapView.settings.myLocationButton = true
      didFindMyLocation = true
    }
  }

}

// Mark: - TransportDelegate
extension TransportViewController: TransportDelegate {

  func connected(transport: Transport) {
    print("Transport was connected")
    transport.subscribe()
  }

  func wasRouted(route: Route, transport: Transport) {
    print("Transport delegate received updated route")
    var locations = route.coordinates()
    if locations.count > 1 {
      let startLocation = locations.removeFirst()
      let endLocation = locations.removeLast()
      getDirections(startLocation, end: endLocation, waypoints: locations)
      markers?.forEach { (m: GMSMarker) -> Void in m.map = nil }
      markers = [GMSMarker]()
      print("Drawing the following commodities to the map: \(route.commodities())")
      route.commodities().forEach { (commodity: Commodity) -> Void in
        let color = randomColor()
        markers?.append(drawMarker(commodity.start!, color: color))
        markers?.append(drawMarker(commodity.destination!, color: color))
      }
    }
  }

  func performedRouteAction(action: RouteAction, transport: Transport) {
    print("Transport delegate notified of performed route action: \(action)")
  }

  func didComeOnline(transport: Transport) {
    print("Transport delegate notified of online transport")
  }

  func didGoOffline(transport: Transport) {
    print("Transport delegate notified of offline transport")
  }
}

// MARK: - GIDSignInDelegate
extension TransportViewController: GIDSignInDelegate {

  func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
    print("GID did sign in for user \(user) with authentication \(user.authentication)")
    setUp()
  }
}

// MARK: - GITClientDelegate
extension TransportViewController: GITClientDelegate {

  func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
    print("GIT finished sign in and returned token \(token) for account \(account) with error \(error)")
    setUp()
  }
}
