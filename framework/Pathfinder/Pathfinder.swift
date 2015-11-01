//
//  Pathfinder.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation
import Starscream

/**
A connection to the Pathfinder service, specific to one authenticated user belonging to a single application.

This is the starting point for all interactions with Pathfinder. The typical use case of this library is:

1. Retrieve a Cluster, either by id or the default cluster of the application. All transports, commodities and routes within specific clusters. Additional clusters can be configured via the Pathfinder web interface.
2. Register as a transport or create a commodity within that cluster.
3. Create a delegate object for the newly created transport or commodity.
4. Respond to the CommodityDelegate or TransportDelegate protocol methods by displaying them on a MapView and executing the appropriate business logic.
*/
public class Pathfinder {
  let applicationIdentifier: String
  let userCredentials: String
  let conn: PathfinderConnection

  /**
  This is the starting point for all interactions with Pathfinder. Once you have constructed a Pathfinder instance, you can begin to interact with transports and commodities.

  - Parameter applicationIdentifier:  The application id that you were assigned when you registered the application through the web portal.
  - Parameter userCredentials:        The credentials that identify and authenticate the user on behalf of whom the connection is opened. The form of these credentials are yet to be determined.
  */
  public init(applicationIdentifier: String, userCredentials: String) {
    self.applicationIdentifier = applicationIdentifier
    self.userCredentials = userCredentials
    self.conn = PathfinderConnection(applicationIdentifier: applicationIdentifier)
  }

  /**
  Retrieves the top-level cluster for the application, including references to all transports and commodities within it. The resulting object can be used to watch for events including transport and commodity updates and route assignments.

  - Parameter callback:  This function will be called exactly once with the populated Cluster object once it is retrieved.
  */
  public func defaultCluster() -> Cluster {
    return Cluster(conn: conn)
  }

  /**
  Retrieves a previously created cluster by id number for the application, including references to all transports and commodities within it. The resuling object can be used to watch for events including transport and commodity updates and route assignments. This method will only need to be used if your application requires Pathfinder subclusters.

  - Paremeter id:        The id of the cluster to retrieve.
  - Parameter callback:  This function will be called exactly once with the populated Cluster object once it is retrieved.
  */
  public func clusterById(id: Int) -> Cluster {
    return Cluster(conn: conn, id: id)
  }
}
