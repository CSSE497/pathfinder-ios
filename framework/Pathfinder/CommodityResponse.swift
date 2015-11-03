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
  let start: CLLocationCoordinate2D
  let destination: CLLocationCoordinate2D
  let param: Int

  class func parse(message: NSDictionary) -> CommodityResponse? {
    if let content = message["created"] as? NSDictionary {
      return parseContent(content)
    } else if let content = message["updated"] as? NSDictionary {
      return parseContent(content)
    } else if let content = message["model"] as? NSDictionary {
      return parseContent(content)
    }
    return nil
  }

  private class func parseContent(content: NSDictionary) -> CommodityResponse? {
    if content["model"] as? String == "Commodity" {
      if let value = content["value"] as? NSDictionary {
        let id = value["id"] as! Int
        let startLat = value["startLatitude"] as! Double
        let startLng = value["startLongitude"] as! Double
        let endLat = value["endLatitude"] as! Double
        let endLng = value["endLongitude"] as! Double
        let param = value["param"] as! Int
        return CommodityResponse(id: id, start: CLLocationCoordinate2D(latitude: startLat, longitude: startLng), destination: CLLocationCoordinate2D(latitude: endLat, longitude: endLng), param: param)
      }
    }
    return nil
  }

  init(id: Int, start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, param: Int) {
    self.id = id
    self.start = start
    self.destination = destination
    self.param = param
  }
}