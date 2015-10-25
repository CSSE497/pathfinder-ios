//
//  ViewController.swift
//  ClusterObserver
//
//  Created by Adam Michael on 10/25/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import UIKit
import Pathfinder

class ViewController: UIViewController {
  let pathfinderAppId: String = "abc"
  let userCredentials: String = "abc"

  var cluster: Cluster!

  @IBOutlet weak var mapView: GMSMapView!

  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up Pathfinder
    cluster = Pathfinder(applicationIdentifier: pathfinderAppId, userCredentials: userCredentials).defaultCluster()
    cluster.delegate = self
    cluster.connect()

    // Set up Google Maps
    mapView.delegate = self
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)

    // Request device location
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

// MARK: - ClusterDelegate
extension ViewController: ClusterDelegate {

  func connectedTo(cluster: Cluster) {

  }

  func vehicleDidComeOnline(vehicle: Vehicle) {

  }

  func vehicleDidGoOffline(vehicle: Vehicle) {

  }

  func commodityWasRequested(commodity: Commodity) {

  }

  func commodityWasPickuped(commodity: Commodity) {

  }

  func commodityWasDroppedOff(commodity: Commodity) {

  }

  func commodityWasCancelled(c: Commodity) {

  }

  func clusterWasRouted(routes: [Route]) {
    
  }

}