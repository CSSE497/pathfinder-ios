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

  let vehicle: Vehicle

  init(vehicle: Vehicle, actions: [RouteAction]) {
    self.vehicle = vehicle
    self.actions = actions
  }

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
    return actions.map { (action: RouteAction) -> Commodity? in action.commodity }.flatMap { $0 }
  }

  class func parse(message: NSDictionary) -> Route? {
    if let actionArray = message["actions"] as? NSArray {
      let actions = actionArray.map { (actionObj: AnyObject) -> RouteAction? in
        if let action = actionObj as? NSDictionary {
          return RouteAction.parse(action)
        }
        return nil
        }.flatMap { $0 }
      if let vehicleDict = message["vehicle"] as? NSDictionary {
        if let vehicle = Vehicle.parse(vehicleDict) {
          return Route(vehicle: vehicle, actions: actions)
        }
      }
    }
    return nil
  }
}

/// A data object containing a commodity, a location and a field indicating pickup or dropoff.
public class RouteAction {

  /// The possible actions that can be performed on commodities by vehicles.
  public enum Action {
    case Start
    case Pickup
    case Dropoff
  }

  /// Whether the action is a pickup or dropoff.
  public let action: Action

  /// The commodity that is picked up or dropped off.
  public var commodity: Commodity?

  /// The location where the action is to occur.
  public let location: CLLocationCoordinate2D

  init(action: Action, location: CLLocationCoordinate2D) {
    self.action = action
    self.location = location
  }

  init(action: Action, commodity: Commodity, location: CLLocationCoordinate2D) {
    self.action = action
    self.commodity = commodity
    self.location = location
  }

  class func parse(message: NSDictionary) -> RouteAction? {
    if let actionString = message["action"] as? String {
      let latitude = message["latitude"] as! Double
      let longitude = message["longitude"] as! Double
      let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      if actionString == "start" {
        return RouteAction(action: Action.Start, location: location)
      } else if actionString == "pickup" {
        if let commodity = Commodity.parse(message["commodity"] as! NSDictionary) {
          return RouteAction(action: Action.Pickup, commodity: commodity, location: location)
        }
      } else if actionString == "dropoff" {
        if let commodity = Commodity.parse(message["commodity"] as! NSDictionary) {
          return RouteAction(action: Action.Dropoff, commodity: commodity, location: location)
        }
      }
    }
    print("Failed to parse RouteAction: \(message)")
    return nil
  }
}

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