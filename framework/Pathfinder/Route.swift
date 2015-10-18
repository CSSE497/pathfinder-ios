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
A list of actions that a vehicle is tasked with. This class provides several view methods to convert the data to a convenient format for plotting or logging. The route is update in real-time by the Pathfinder service. To be notified of updates, you will need to implement one of ClusterDelegate, CommodityDelegate or VehicleDelegate.

This class should never be instantiated directly because it represents the state of the data from the Pathfinder backend. Instead, routes can be obtained by querying Cluster, Vehicle or Commodity object properties or by instantiating a ClusterDelegate, CommodityDelegate or VehicleDelegate.
*/
public class Route {

  /// The queue of actions that make up the route.
  public let actions: [RouteAction]

  init() {
    actions = [RouteAction]()
  }

  /**
  Converts the array of RouteAction to an array of CLLocationCoordinate2D.

  - Returns:  An array of CLLocationCoordinate2D objects representing the route.
  */
  public func asCoordinates() -> [CLLocationCoordinate2D] {
    return actions.map({action in action.location})
  }
}

/// A data object containing a commodity, a location and a field indicating pickup or dropoff.
public class RouteAction {

  /// The possible actions that can be performed on commodities by vehicles.
  public enum Action {
    case Pickup
    case Dropoff
  }

  /// Whether the action is a pickup or dropoff.
  public let action: Action

  /// The commodity that is picked up or dropped off.
  public let commodity: Commodity

  /// The location where the action is to occur.
  public let location: CLLocationCoordinate2D

  init(action: Action, commodity: Commodity, location: CLLocationCoordinate2D) {
    self.action = action
    self.commodity = commodity
    self.location = location
  }
}