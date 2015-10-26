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
  let pathfinderAppId: String = "9c4166bb-9535-49e1-8844-1904a0b1f45b"
  let userCredentials: String = "abc"

  var vehicle: Vehicle!

  let locationManager = CLLocationManager()

  @IBOutlet weak var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up Pathfinder
    vehicle = Pathfinder(applicationIdentifier: pathfinderAppId, userCredentials: userCredentials).defaultCluster().createVehicle(["chimney": 3])
    vehicle.delegate = self
    vehicle.connect()

    // Set up Google Maps
    mapView.delegate = self
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)

    // Request device location
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      mapView.myLocationEnabled = true
    }
  }

}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
    mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
    mapView.settings.myLocationButton = true
  }
  
}

// Mark: - VehicleDelegate
extension ViewController: VehicleDelegate {

  func performedRouteAction(action: RouteAction, vehicle: Vehicle) {

  }

  func wasRouted(route: Route, vehicle: Vehicle) {

  }

  func didComeOnline(vehicle: Vehicle) {

  }

  func didGoOffline(vehicle: Vehicle) {

  }
}

