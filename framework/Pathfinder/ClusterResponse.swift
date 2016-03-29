//
//  ClusterResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

class ClusterResponse {
  let id: String
  let transports: [Transport]
  let commodities: [Commodity]

  class func parse(message: NSDictionary) -> ClusterResponse? {
    if message["message"] as! String == "Model" && message["model"] as! String == "Cluster" {
      let value = message["value"] as! NSDictionary
      let clusterId = value["id"] as! String
      let transports = (value["transports"] as! NSArray).map() { (anyObj: AnyObject) -> Transport in
        let transportDict = anyObj as! NSDictionary
        let id = transportDict["id"] as! Int
        let rawStatus = transportDict["status"] as! String
        let status = Transport.Status(rawValue: rawStatus)!
        let metadata = transportDict["metadata"] as! [String:AnyObject]
        let location = CLLocationCoordinate2D(latitude: transportDict["latitude"] as! Double, longitude: transportDict["longitude"] as! Double)
        return Transport(clusterId: clusterId, id: id, metadata: metadata, location: location, status: status)
      }
      let commodities = (value["commodities"] as! NSArray).map() { (anyObj: AnyObject) -> Commodity in
        let commodityDict = anyObj as! NSDictionary
        let id = commodityDict["id"] as! Int
        let start = CLLocationCoordinate2D(latitude: commodityDict["startLatitude"] as! Double, longitude: commodityDict["startLongitude"] as! Double)
        let destination = CLLocationCoordinate2D(latitude: commodityDict["endLatitude"] as! Double, longitude: commodityDict["endLongitude"] as! Double)
        let metadata = commodityDict["metadata"] as! [String:AnyObject]
        return Commodity(clusterId: clusterId, id: id, start: start, destination: destination, metadata: metadata)
      }
      return ClusterResponse(id: clusterId, transports: transports, commodities: commodities)
    }
    return nil
  }

  init(id: String, transports: [Transport], commodities: [Commodity]) {
    self.id = id
    self.transports = transports
    self.commodities = commodities
  }
}