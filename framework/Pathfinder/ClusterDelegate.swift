//
//  ClusterDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
Receives notifications of updates to a Cluster within the context of the specific application.

The standard use case is to update views and execute billing and other business logic.
*/
public protocol ClusterDelegate {

  /**
  The connection to the cluster has been established.
  
  - Parameter cluster:  The newly connected cluster.
  */
  func connected(cluster: Cluster)

  /**
  A transport that was previously offline or did not exist is now online and ready to be routed in the cluster.

  - Parameter transport: The newly online transport.
  */
  func transportDidComeOnline(transport: Transport)

  /**
  A transport that was previously online is now offline. If the transport was assigned a route, all commodities on that route will be reassigned.

  - Parameter transport: The newly offline transport.
  */
  func transportDidGoOffline(transport: Transport)

  /**
  A new commodity requested transportation within the cluster.

  - Parameter commodity: The commodity that is waiting to be picked up.
  */
  func commodityWasRequested(commodity: Commodity)

  /**
  A commodity was picked up by a transport.

  - Parameter commodity: The commodity that is now in transit to its destination.
  */
  func commodityWasPickuped(commodity: Commodity)

  /**
  A commodity was dropped off at its destination.

  - Parameter commodity: The commodity that was just dropped off at its destination.
  */
  func commodityWasDroppedOff(commodity: Commodity)

  /**
  A commodity cancelled its request for transportation. It will not be transported to its destination.

  - Parameter commodity: The commodity that cancelled its transportation request.
  */
  func commodityWasCancelled(commodity: Commodity)

  /**
  The routing for the cluster was updated. Since every transport in a cluster has the potential to transport any transport in the same cluster, routes are calculated on a cluster level. When this method is called, all previously provided routes should be considered obsolete.

  - Parameter routes: All of the routes for the cluster.
  */
  func clusterWasRouted(routes: [Route])
}
