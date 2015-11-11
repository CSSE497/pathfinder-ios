//
//  TransportDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/17/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
Receives notifications of updates to a transport within the context of the specific application.

The standard use cases are two-fold:

1. To notify the transport driver of route changes.
2. To notify a commodity who is waiting on a transport of that transports actions.
*/
public protocol TransportDelegate {

  /**
   The connection to the transport has been established.

   - Parameter transport:  The transport that was connected.
   */
  func connected(transport: Transport)

  /**
  The transport performed a pickup or dropoff action.

  - Parameter action:   The action that was performed, including the related commodity.
  - Parameter transport:  The transport that performed the pickup or drop off.
  */
  func performedRouteAction(action: RouteAction, transport: Transport)

  /**
  The transport was assigned a route. This route supercedes all previous routes. Stale routes should be discarded.

  - Parameter route:    The route that the transport is assigned to.
  - Parameter transport:  The transport that received a route assignment.
  */
  func wasRouted(route: Route, transport: Transport)

  /**
  The transport was previous offline but now it is online.

  - Parameter transport:  The transport that came online.
  */
  func didGoOnline(transport: Transport)

  /**
  The transport was previously online but now it is offline.

  - Parameter transport:  The transport that went offline.
  */
  func didGoOffline(transport: Transport)
}