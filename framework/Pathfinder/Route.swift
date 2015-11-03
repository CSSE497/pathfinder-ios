//
//  Route.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/17/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/**
A list of actions that a transport is tasked with. This class provides several view methods to convert the data to a convenient format for plotting or logging. The route is update in real-time by the Pathfinder service. To be notified of updates, you will need to implement one of ClusterDelegate, CommodityDelegate or TransportDelegate.

This class should never be instantiated directly because it represents the state of the data from the Pathfinder backend. Instead, routes can be obtained by querying Cluster, Transport or Commodity object properties or by instantiating a ClusterDelegate, CommodityDelegate or TransportDelegate.
*/
public class Route {

  // MARK: - Instance Variables

  /// The queue of RouteActions that make up the route.
  public let actions: [RouteAction]

  /// The transport instance that is assigned to the route.
  public let transport: Transport

  init(transport: Transport, actions: [RouteAction]) {
    self.transport = transport
    self.actions = actions
  }

  // MARK: - Methods -

  /**
  Converts the array of RouteAction to an array of CLLocationCoordinate2D.

  - Returns:  An array of CLLocationCoordinate2D objects representing the route.
  */
  public func coordinates() -> [CLLocationCoordinate2D] {
    return actions.map({action in action.location})
  }

  /**
  Get's the commodities in the route. This is helpful for display extra information that is stored with the commodity and for determining pairs to draw on a map.
   
  - Returns:  The commodities that are picked up and dropped off on the route.
  */
  public func commodities() -> [Commodity] {
    var result = [Commodity]()
    for (index, value) in actions.enumerate() {
      if index % 2 == 1 {
        result.append(value.commodity!)
      }
    }
    return result
  }

  class func parse(message: NSDictionary) -> Route? {
    if let actionArray = message["actions"] as? NSArray {
      let actions = actionArray.map { (actionObj: AnyObject) -> RouteAction in
        return RouteAction.parse(actionObj as! NSDictionary)!
      }
      if let transportDict = message["vehicle"] as? NSDictionary {
        if let transport = Transport.parse(transportDict) {
          print("Parsed route with \(actions.count) actions")
          return Route(transport: transport, actions: actions)
        }
      }
    }
    return nil
  }
}