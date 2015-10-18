//
//  VehicleDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/17/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
Receives notifications of updates to a vehicle within the context of the specific application.

The standard use cases are two-fold:

1. To notify the vehicle driver of route changes.
2. To notify a commodity who is waiting on a vehicle of that vehicles actions.
*/
public protocol VehicleDelegate {

  /**
  The vehicle performed a pickup or dropoff action.

  - Parameter action:   The action that was performed, including the related commodity.
  - Parameter vehicle:  The vehicle that performed the pickup or drop off.
  */
  func performedRouteAction(action: RouteAction, vehicle: Vehicle)

  /**
  The vehicle was assigned a route. This route supercedes all previous routes. Stale routes should be discarded.

  - Parameter route:    The route that the vehicle is assigned to.
  - Parameter vehicle:  The vehicle that received a route assignment.
  */
  func wasRouted(route: Route, vehicle: Vehicle)

  /**
  The vehicle was previous offline but now it is online.

  - Parameter vehicle:  The vehicle that came online.
  */
  func didComeOnline(vehicle: Vehicle)

  /**
  The vehicle was previously online but now it is offline.

  - Parameter vehicle:  The vehicle that went offline.
  */
  func didGoOffline(vehicle: Vehicle)
}