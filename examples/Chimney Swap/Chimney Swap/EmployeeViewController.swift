//
//  EmployeeViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import thepathfinder

class EmployeeViewController: UIViewController {
  var transport: Transport!
  var mapTasks: MapTasks!

  var locationManager = CLLocationManager()
  var didFindMyLocation = false

  @IBOutlet weak var onlineControl: UISegmentedControl!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var nextAction: UILabel!
  @IBOutlet weak var completeActionButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up Pathfinder. Subscribe to the transport after the connection is confirmed.
//    let userCreds = NSUserDefaults.standardUserDefaults().objectForKey(Constants.ChimneySwap.customerToken) as! String
    let path = "/root/midwest/th"
    let cluster = Pathfinder(applicationIdentifier: Constants.Pathfinder.applicationId, userCredentials: "").cluster(path)
    transport = cluster.createTransport(Transport.Status.Offline, metadata: ["chimney": 1])
    transport.delegate = self
    transport.connect()

    // Set up Google Maps
    mapView.delegate = self
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    mapTasks = MapTasks(mapView: mapView)

    // Request device location
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }

  @IBAction func online(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: // Online
      print("Attempting to bring vehicle online")
      transport.goOnline()
    case 1: // Offline
      print("Attempting to take vehicle offline")
      transport.goOffline()
      mapTasks.clear()
    default:
      break
    }
  }

  @IBAction func completeAction() {
    transport.completeNextRouteAction()
  }
}

extension EmployeeViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("ViewController is now authorized to view location.")
    if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
      mapView.myLocationEnabled = true
      transport.connect()
    }
  }
}

extension EmployeeViewController: GMSMapViewDelegate {

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if !didFindMyLocation {
      let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
      mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
      mapView.settings.myLocationButton = true
      didFindMyLocation = true
    }
  }
}

extension EmployeeViewController: TransportDelegate {

  func connected(transport: Transport) {
    print("Transport was connected")
    transport.subscribe()
  }

  func wasRouted(route: Route, transport: Transport) {
    print("Transport delegate received updated route")
    if transport.status == Transport.Status.Online {
      if route.actions.count > 1 {
        nextAction.text = "\(route.actions[1].action.description) Chimney"
        completeActionButton.enabled = true
        nextAction.enabled = true
      } else {
        nextAction.text = "No chimneys"
        completeActionButton.enabled = false
        nextAction.enabled = false
      }
      mapTasks.draw(route)
    }
  }

  func performedRouteAction(action: RouteAction, transport: Transport) {
    print("Transport delegate notified of performed route action: \(action)")
  }

  func didGoOnline(transport: Transport) {
    print("Transport delegate notified of online transport")
  }

  func didGoOffline(transport: Transport) {
    print("Transport delegate notified of offline transport")
  }
}
