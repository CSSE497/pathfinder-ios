//
//  ViewController.swift
//  ClusterObserver
//
//  Created by Adam Michael on 10/25/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import UIKit
import thepathfinder

class ViewController: UIViewController {
  let pathfinderAppId = "9869bd06-12ec-451f-8207-2c5f217eb4d0"
  let userCredentials = "abc"
  let baseDirectionsUrl = "https://maps.googleapis.com/maps/api/directions/json?"
  let apiKey = "AIzaSyCxkw1-mYOy6nsSTdyQ6CIjOjIRP33iIxY"

  var cluster: Cluster!
  var drawnPaths = [GMSPolyline]()
  var existingMarkers = [Double]()

  @IBOutlet weak var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up Pathfinder
    cluster = Pathfinder(applicationIdentifier: pathfinderAppId, userCredentials: userCredentials).cluster()
    cluster.delegate = self
    cluster.connect()

    let target = CLLocationCoordinate2DMake(40.65325, -87.5373)
    mapView.camera = GMSCameraPosition.cameraWithTarget(target, zoom: 7.5)
  }

  func draw(coordinate: CLLocationCoordinate2D, icon: UIImage, opacity: Float) {
    if !existingMarkers.contains(coordinate.latitude*coordinate.longitude) {
      print("Drawing marker at \(coordinate)")
      let marker = GMSMarker(position: coordinate)
      marker.map = mapView
      marker.appearAnimation = kGMSMarkerAnimationPop
      marker.icon = icon
      marker.opacity = opacity
      existingMarkers.append(coordinate.longitude*coordinate.latitude)
    }
  }

  func getDirections(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], color: UIColor) {
    var directionsUrl = "\(baseDirectionsUrl)origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)"
    if !waypoints.isEmpty {
      directionsUrl += "&waypoints=" + waypoints.map { (c: CLLocationCoordinate2D) -> String in "\(c.latitude),\(c.longitude)" }.joinWithSeparator("|")
    }
    let directionsNSUrl = NSURL(string: directionsUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    print("Requesting directions from \(directionsNSUrl)")
    dispatch_async(dispatch_get_main_queue()) {
      let directionsData = NSData(contentsOfURL: directionsNSUrl!)
      do {
        let response = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! [NSObject:AnyObject]
        if let routes = response["routes"] as? [[NSObject:AnyObject]] {
          if let overviewPolyline = routes.first?["overview_polyline"] as? [NSObject:AnyObject] {
            self.draw(GMSPath(fromEncodedPath: overviewPolyline["points"] as! String), color: color)
          } else {
            print("Google Maps response missing overview polyline: \(routes)")
          }
        } else {
          print("Google Maps response missing routes field")
        }
      } catch {
        print("Unable to parse directions response from Google Maps: \(error)")
      }
    }
  }

  func draw(path: GMSPath, color: UIColor) {
    let drawnPath = GMSPolyline(path: path)
    drawnPath?.map = mapView
    drawnPath?.strokeWidth = 4
    drawnPath?.strokeColor = color
    drawnPaths.append(drawnPath)
  }

  func draw(route: Route, color: UIColor) {
    for action in route.actions {
      if action.commodity != nil {
        let color = randomColor()
        draw(action.commodity!.start!, icon: GMSMarker.markerImageWithColor(color), opacity: 1.0)
        draw(action.commodity!.destination!, icon: GMSMarker.markerImageWithColor(color), opacity: 0.5)
      }
    }
    var locations = route.coordinates()
    if locations.count > 1 {
      let startLocation = locations.removeFirst()
      let endLocation = locations.removeLast()
      getDirections(startLocation, end: endLocation, waypoints: locations, color: color)
    }
  }

  func randomColor() -> UIColor {
    return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
  }
}

// MARK: - ClusterDelegate
extension ViewController: ClusterDelegate {

  func connected(cluster: Cluster) {
    print("Cluster connected: \(cluster)")
    for c in cluster.commodities {
      let color = randomColor()
      draw(c.start!, icon: GMSMarker.markerImageWithColor(color), opacity: 1.0)
      draw(c.destination!, icon: GMSMarker.markerImageWithColor(color), opacity: 0.5)
    }

    for t in cluster.transports {
      draw(t.location!, icon: UIImage(named: "car.png")!, opacity: 1.0)
    }

    cluster.subscribe()
  }

  func transportDidComeOnline(transport: Transport) {
    print("Transport did come online: \(transport)")
  }

  func transportDidGoOffline(transport: Transport) {
    print("Transport did go offline: \(transport)")
  }

  func commodityWasRequested(commodity: Commodity) {
    print("Commodity was requested: \(commodity)")
  }

  func commodityWasPickuped(commodity: Commodity) {
    print("Commodity was picked up: \(commodity)")
  }

  func commodityWasDroppedOff(commodity: Commodity) {
    print("Commodity was dropped off: \(commodity)")
  }

  func commodityWasCancelled(c: Commodity) {
    print("Commodity was cancelled: \(c)")
  }

  func clusterWasRouted(routes: [Route]) {
    print("Commodity was routed: \(routes)")
    for drawnPath in drawnPaths {
      drawnPath.map = nil
    }
    drawnPaths.removeAll()
    for route in routes {
      draw(route, color: randomColor())
    }
  }
}