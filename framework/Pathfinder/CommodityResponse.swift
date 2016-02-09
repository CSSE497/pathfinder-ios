//
//  CommodityResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

class CommodityResponse {
  let id: Int
  let clusterId: String
  let start: CLLocationCoordinate2D
  let destination: CLLocationCoordinate2D
  let metadata: [String:AnyObject]
  let status: Commodity.Status

  class func parse(message: NSDictionary) -> CommodityResponse? {
    if message["model"] as? String == "Commodity" {
      if message["message"] as? String == "Created" || message["message"] as? String == "Updated" {
        return parseContent(message["value"] as! NSDictionary)
      }
    }
    return nil
  }

  private class func parseContent(value: NSDictionary) -> CommodityResponse? {
    let id = value["id"] as! Int
    let startLat = value["startLatitude"] as! Double
    let startLng = value["startLongitude"] as! Double
    let endLat = value["endLatitude"] as! Double
    let endLng = value["endLongitude"] as! Double
    let status = Commodity.Status(rawValue: value["status"] as! String)!
    let metadata = value["metadata"] as! [String:AnyObject]
    let clusterId = value["clusterId"] as! String
    return CommodityResponse(id: id, clusterId: clusterId, start: CLLocationCoordinate2D(latitude: startLat, longitude: startLng), destination: CLLocationCoordinate2D(latitude: endLat, longitude: endLng), status: status, metadata: metadata)
  }

  init(id: Int, clusterId: String, start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, status: Commodity.Status, metadata: [String:AnyObject]) {
    self.id = id
    self.clusterId = clusterId
    self.start = start
    self.destination = destination
    self.status = status
    self.metadata = metadata
  }
}