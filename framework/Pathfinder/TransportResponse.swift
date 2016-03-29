//
//  TransportResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

class TransportResponse {
  let id: Int
  let clusterId: String
  let location: CLLocationCoordinate2D
  let metadata: [String:AnyObject]

  class func parse(message: NSDictionary) -> TransportResponse? {
    if message["model"] as? String == "Transport" {
      if message["message"] as? String == "Created" || message["message"] as? String == "Updated" {
        let value = message["value"] as! NSDictionary
        let id = value["id"] as! Int
        let clusterId = value["clusterId"] as! String
        let lat = value["latitude"] as! Double
        let lng = value["longitude"] as! Double
        let metadata = value["metadata"] as! [String:AnyObject]
        return TransportResponse(id: id, clusterId: clusterId, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), metadata: metadata)
      }
    }
    return nil
  }

  init(id: Int, clusterId: String, location: CLLocationCoordinate2D, metadata: [String:AnyObject]) {
    self.id = id
    self.clusterId = clusterId
    self.location = location
    self.metadata = metadata
  }
}