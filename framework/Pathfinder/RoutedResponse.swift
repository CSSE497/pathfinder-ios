//
//  RoutedResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class RoutedResponse {
  class func parse(message: NSDictionary) -> RoutedResponse? {
    if let routed = message["routed"] as? NSDictionary {
      let model = routed["model"] as! String
      if let routeDict = routed["route"] as? NSDictionary {
        if let route = Route.parse(routeDict) {
          return RoutedResponse(model: model, route: route)
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