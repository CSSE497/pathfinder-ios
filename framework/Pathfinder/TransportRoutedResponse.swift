//
//  TransportRoutedResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class TransportRoutedResponse {
  class func parse(message: NSDictionary) -> TransportRoutedResponse? {
    if message["message"] as? String == "Routed" && message["model"] as? String == "Vehicle" {
      if let routeDict = message["route"] as? NSDictionary {
        if let route = Route.parse(routeDict) {
          return TransportRoutedResponse(route: route)
        }
      }
    }
    return nil
  }

  let route: Route

  init(route: Route) {
    self.route = route
  }
}