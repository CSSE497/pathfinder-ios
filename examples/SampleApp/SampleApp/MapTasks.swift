//
//  MapTasks.swift
//  SampleApp
//
//  Created by Adam Michael on 10/4/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class MapTasks: NSObject {
    let baseDirectionsUrl = "https://maps.googleapis.com/maps/api/directions/json?"
    
    func getDirections(path: [CLLocationCoordinate2D], vehicleId: Int, completionHandler: ((vehicleId: Int, encodedPath: String) -> Void)) {
        var path = path
        let origin = path.removeFirst()
        let destination = path.removeLast()
        var directionsUrlString = baseDirectionsUrl + "origin=\(origin.latitude),\(origin.longitude)"
        directionsUrlString += "&destination=\(destination.latitude),\(destination.longitude)"
        if !path.isEmpty {
            directionsUrlString += "&waypoints=optimize:true"
            for point in path {
                directionsUrlString += "|\(point.latitude),\(point.longitude)"
            }
        }
        directionsUrlString = directionsUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        print("Attempting to connect to \(directionsUrlString)")
        let directionsUrl = NSURL(string: directionsUrlString)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let directionsData = NSData(contentsOfURL: directionsUrl!)
            do {
                let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                let status = dictionary["status"] as! String
                if status == "OK" {
                    let selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                    let overviewPolyline = selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                    completionHandler(vehicleId: vehicleId, encodedPath: overviewPolyline["points"] as! String)
                } else {
                    print("Google directions did not return status OK")
                    print(dictionary)
                }
            } catch {
                print(error)
            }
        })
    }
}
