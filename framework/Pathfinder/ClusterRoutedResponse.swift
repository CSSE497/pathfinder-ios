//
//  ClusterRoutedResponse.swift
//  Pods
//
//  Created by Adam Michael on 12/15/15.
//
//

import Foundation

class ClusterRoutedResponse {
  class func parse(message: NSDictionary) -> ClusterRoutedResponse? {
    if message["message"] as! String == "Routed" && message["model"] as! String == "Cluster" {
      let value = message["value"] as! NSDictionary
      let id = value["id"] as! Int
      let routeArr = message["route"] as! NSArray
      var routes = [Route]()
      for routeObj in routeArr {
        let routeDict = routeObj as! NSDictionary
        let route = Route.parse(routeDict)
        routes.append(route!)
      }
      return ClusterRoutedResponse(id: id, routes: routes)
    }
    return nil
  }

  let id: Int
  let routes: [Route]

  init(id: Int, routes: [Route]) {
    self.id = id
    self.routes = routes
  }
}