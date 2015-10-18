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

1. Retrieve a Cluster, either by id or the default cluster of the application. All vehicles, commodities and routes within specific clusters. Additional clusters can be configured via the Pathfinder web interface.
2. Register as a vehicle or create a commodity within that cluster.
3. Create a delegate object for the newly created vehicle or commodity.
4. Respond to the CommodityDelegate or VehicleDelegate protocol methods by displaying them on a MapView and executing the appropriate business logic.
*/
public class Pathfinder {
  let applicationIdentifier: String
  let userCredentials: String

  /**
  This is the starting point for all interactions with Pathfinder. Once you have constructed a Pathfinder instance, you can begin to interact with vehicles and commodities.

  - Parameter applicationIdentifier:  The application id that you were assigned when you registered the application through the web portal.
  - Parameter userCredentials:        The credentials that identify and authenticate the user on behalf of whom the connection is opened. The form of these credentials are yet to be determined.
  */
  public init(applicationIdentifier applicationIdentifier: String, userCredentials: String) {
    self.applicationIdentifier = applicationIdentifier
    self.userCredentials = userCredentials
  }

  /**
  Retrieves the top-level cluster for the application, including references to all vehicles and commodities within it. The resulting object can be used to watch for events including vehicle and commodity updates and route assignments.

  - Parameter callback:  This function will be called exactly once with the populated Cluster object once it is retrieved.
  */
  public func defaultCluster(callback callback: (cluster: Cluster) -> Void) {

  }

  /**
  Retrieves a previously created cluster by id number for the application, including references to all vehicles and commodities within it. The resuling object can be used to watch for events including vehicle and commodity updates and route assignments. This method will only need to be used if your application requires Pathfinder subclusters.

  - Paremeter id:        The id of the cluster to retrieve.
  - Parameter callback:  This function will be called exactly once with the populated Cluster object once it is retrieved.
  */
  public func clusterById(id: Int, callback: (cluster: Cluster) -> Void) {

  }

  /**
  Registers the current device as a vehicle with the Pathfinder service or uses the user's authentication to determine if an existing vehicle record exists and retrieves it. This will NOT set the vehicle to the online state. No routes will be generated for the vehicle until it is set to online.

  - Parameter cluster:     The cluster to register the vehicle within. Pathfinder does not support moving vehicles between clusters, so the cluster in which the vehicle is created restricts the routes to which it can be assigned.
  - Parameter capacities:  The limiting constraints of the vehicle of the parameters of your application's routing calculations. The set of parameters needs to be defined and prioritized via the Pathfinder web interface in advance. All vehicles will be routed while keeping their sum occupant parameters to be less than or equal to their limiting constraints.
  - Parameter callback:    This function will be called exactly once with the registered Vehicle object. The Vehicle object can be used to set the vehicle as online or offline, to receive route assignments and send updates regarding pickups and dropoffs.
  */
  public func connectDeviceAsVehicle(cluster cluster: Cluster, parameterCapacities: [String:Int], callback: (vehicle: Vehicle) -> Void) {

  }

  /**
  Requests transportation for a physical entity from one geographical location to another. This will immediately route a vehicle to pick up the commodity if one is available that can hold the commodities parameters within the vehicles capacity.

  - Parameter cluster:      The cluster to request commodity transit within. Pathfinder does not support moving commodities between clusters after they have been created. The cluster in which the commodity is created determines the set of vehicles that can transport it and the set of other commodities that can share transit with it.
  - Parameter start:        The starting location of the commodity.
  - Parameter destination:  The destination location of the commodity.
  - Parameter parameters:   The quantities the parameters of your application's routing calculations. The set of parameters needs to be defined and prioritized via the Pathfinder web interface in advance.
  - Parameter callback:    This function will be called exactly once with the created Commodity object. The Commodity object can be used to receive updates on status, ro utes and cancel the request if needed.
  */
  public func requestCommodityTransit(cluster cluster: Cluster, start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, parameters: [String:Int], callback: (c: Commodity) -> Void) {

  }
}
