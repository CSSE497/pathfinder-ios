//
//  ClusterDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
Handles udpates to a Cluster within the context of the specific application.

The standard use case is to update views and executing billing and other business logic.
*/
public protocol ClusterDelegate {

  /**
  A vehicle that was previously offline or did not exist is now online and ready to be routed in the cluster.

  Parameter vehicle: The newly online vehicle.
  */
  func vehicleDidComeOnline(vehicle: Vehicle)

  /**
  A vehicle that was previously online is now offline. If the vehicle was assigned a route, all commodities on that route will be reassigned.
  
  Parameter vehicle: The newly offline vehicle.
  */
  func vehicleDidGoOffline(vehicle: Vehicle)

  /**
  A new commodity requested transportation within the cluster.

  Parameter commodity: The commodity that is waiting to be picked up.
  */
  func commodityWasRequested(commodity: Commodity)

  /**
  A commodity was picked up by a vehicle.

  Parameter commodity: The commodity that is now in transit to its destination.
  */
  func commodityWasPickuped(commodity: Commodity)

  /**
  A commodity was dropped off at its destination.

  Parameter commodity: The commodity that was just dropped off at its destination.
  */
  func commodityWasDroppedOff(commodity: Commodity)

  /**
  A commodity cancelled its request for transportation. It will not be transported to its destination.

  Parameter commodity: The commodity that cancelled its transportation request.
  */
  func commodityWasCancelled(c: Commodity)

  /**
  The routing for the cluster was updated. Since every vehicle in a cluster has the potential to transport any vehicle in the same cluster, routes are calculated on a cluster level. When this method is called, all previously provided routes should be considered obsolete.

  Parameter routes: All of the routes for the cluster.
  */
  func clusterWasRouted(routes: [Route])
}