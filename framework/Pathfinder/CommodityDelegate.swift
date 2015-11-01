//
//  CommodityDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/**
Receives notifications of updates to a Commodity within the context of the specific application.

The standard use cases are to notify the requesting user that a transport has been dispatched to transport them or to observe the state of a commodity in transit from a third part perspective. Note that the transport is responsible for notifying the service that it has picked up or dropped off a commodity, not the commodity itself.
*/
public protocol CommodityDelegate {

  /**
  A commodity was connected to the Pathfinder backend.

  - Parameter commodity:  The commodity that was connected.
  */
  func connected(commodity: Commodity)

  /**
  A commodity was picked up at its starting location.
  
  - Parameter location:   The location where the commodity was picked up.
  - Parameter commodity:  The commodity that was picked up.
  - Parameter byTransport:  The transport that is now transporting the commodity.
  */
  func wasPickedUpAt(location: CLLocationCoordinate2D, commodity: Commodity, byTransport: Transport)

  /**
  A commodity was dropped off at its destination.

  - Parameter location:   The location where the commodity was dropped off.
  - Parameter commodity:  The commodity that was dropped off.
  */
  func wasDroppedOffAt(location: CLLocationCoordinate2D, commodity: Commodity)

  /**
  A commodity transportation request was cancelled.

  - Parameter commodity: The commodity that will no longer be transported.
  */
  func wasCancelled(commodity: Commodity)

  /**
  A route was generated for a transport that includes this commodity.
  
  - Parameter commodity:  The commodity that will be transported.
  - Parameter transport:    The transport that will transport the commodity.
  - Paramter onRoute:     The route which contains the other commodities that will be picked up by the transport.
  */
  func wasRouted(commodity: Commodity, byTransport: Transport, onRoute: Route)
}