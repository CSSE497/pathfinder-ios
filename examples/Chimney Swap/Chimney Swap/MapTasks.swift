//
//  MapTasks.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/10/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import thepathfinder

class MapTasks {
  
  weak var mapView: GMSMapView!
  var drawnPath: GMSPolyline?
  var markers: [GMSMarker]?

  init(mapView: GMSMapView!) {
    self.mapView = mapView
  }

  func draw(coordinate: CLLocationCoordinate2D, icon: UIImage) -> GMSMarker {
    print("Drawing marker at \(coordinate)")
    let marker = GMSMarker(position: coordinate)
    marker.map = mapView
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.icon = icon
    return marker
  }

  func draw(path: GMSPath) {
    drawnPath?.map = nil
    drawnPath = GMSPolyline(path: path)
    drawnPath?.map = mapView
    drawnPath?.strokeWidth = 4
  }

  func draw(route: Route) {
    print("Drawing a route of size \(route.actions.count) with \(route.commodities().count) commodities")
    var locations = route.coordinates()
    if locations.count > 1 {
      let startLocation = locations.removeFirst()
      let endLocation = locations.removeLast()
      getDirections(startLocation, end: endLocation, waypoints: locations)
      markers?.forEach { (m: GMSMarker) -> Void in m.map = nil }
      markers = [GMSMarker]()
      print("Drawing the following commodities to the map: \(route.commodities())")
      route.commodities().forEach { (commodity: Commodity) -> Void in
        markers?.append(draw(commodity.start!, icon: UIImage(named: "chimney.png")!))
        markers?.append(draw(commodity.destination!, icon: UIImage(named: "finish_flag.png")!))
      }
    }
  }

  func getDirections(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D]) {
    var directionsUrl = "\(Constants.Google.directionsUrl)origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)"
    if !waypoints.isEmpty {
      directionsUrl += "&waypoints=optimize:true" + waypoints.map { (c: CLLocationCoordinate2D) -> String in "|\(c.latitude),\(c.longitude)" }.joinWithSeparator("")
    }
    let directionsNSUrl = NSURL(string: directionsUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    print("Requesting directions from \(directionsNSUrl)")
    dispatch_async(dispatch_get_main_queue()) {
      let directionsData = NSData(contentsOfURL: directionsNSUrl!)
      do {
        let response = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! [NSObject:AnyObject]
        if let routes = response["routes"] as? [[NSObject:AnyObject]] {
          if let overviewPolyline = routes.first?["overview_polyline"] as? [NSObject:AnyObject] {
            self.draw(GMSPath(fromEncodedPath: overviewPolyline["points"] as! String)!)
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

  func clear() {
    markers?.forEach { (m: GMSMarker) -> Void in m.map = nil }
    markers = [GMSMarker]()
    drawnPath?.map = nil
    drawnPath = nil
  }
}
