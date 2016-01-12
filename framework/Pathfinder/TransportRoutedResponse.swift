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
    if let routed = message["routed"] as? NSDictionary {
      let model = routed["model"] as! String
      if let routeDict = routed["route"] as? NSDictionary {
        if let route = Route.parse(routeDict) {
          return TransportRoutedResponse(model: model, route: route)
        }
      }
    }
    return nil
  }

  let model: String
  let route: Route

  init(model: String, route: Route) {
    self.model = model
    self.route = route
  }
}