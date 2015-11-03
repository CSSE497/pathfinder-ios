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
  let location: CLLocationCoordinate2D
  let capacity: Int

  class func parse(message: NSDictionary) -> TransportResponse? {
    if let update = message["updated"] as? NSDictionary {
      if update["model"] as? String == "Vehicle" {
        let value = update["value"] as! NSDictionary
        let id = value["id"] as! Int
        let lat = value["latitude"] as! Double
        let lng = value["longitude"] as! Double
        return TransportResponse(id: id, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), capacity: 3)
      }
    }
    if let update = message["created"] as? NSDictionary {
      if update["model"] as? String == "Vehicle" {
        let value = update["value"] as! NSDictionary
        let id = value["id"] as! Int
        let lat = value["latitude"] as! Double
        let lng = value["longitude"] as! Double
        return TransportResponse(id: id, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), capacity: 3)
      }
    }
    return nil
  }

  init(id: Int, location: CLLocationCoordinate2D, capacity: Int) {
    self.id = id
    self.location = location
    self.capacity = capacity
  }
}