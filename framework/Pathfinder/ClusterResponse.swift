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
  let id: Int
  let transports: [Transport]
  let commodities: [Commodity]

  class func parse(message: NSDictionary) -> ClusterResponse? {
    if let model: NSDictionary = message["model"] as? NSDictionary {
      if model["model"] as? String == "Cluster" {
        if let value: NSDictionary = model["value"] as? NSDictionary {
          let clusterId = value["id"] as! Int
          let transports = (value["vehicles"] as! NSArray).map() { (anyObj: AnyObject) -> Transport in
            let transportDict = anyObj as! NSDictionary
            let id = transportDict["id"] as! Int
            let rawStatus = transportDict["status"] as! String
            let status = Transport.Status(rawValue: rawStatus)!
            let capacities = ["chimney":transportDict["capacity"] as! Int]
            let location = CLLocationCoordinate2D(latitude: transportDict["latitude"] as! Double, longitude: transportDict["longitude"] as! Double)
            return Transport(clusterId: clusterId, id: id, capacities: capacities, location: location, status: status)
          }
          let commodities = (value["commodities"] as! NSArray).map() { (anyObj: AnyObject) -> Commodity in
            let commodityDict = anyObj as! NSDictionary
            let id = commodityDict["id"] as! Int
            let start = CLLocationCoordinate2D(latitude: commodityDict["startLatitude"] as! Double, longitude: commodityDict["startLongitude"] as! Double)
            let destination = CLLocationCoordinate2D(latitude: commodityDict["endLatitude"] as! Double, longitude: commodityDict["endLongitude"] as! Double)
            let parameters = ["chimney":commodityDict["param"] as! Int]
            return Commodity(clusterId: clusterId, id: id, start: start, destination: destination, parameters: parameters)
          }
          return ClusterResponse(id: clusterId, transports: transports, commodities: commodities)
        }
      }
    }
    return nil
  }

  init(id: Int, transports: [Transport], commodities: [Commodity]) {
    self.id = id
    self.transports = transports
    self.commodities = commodities
  }
}