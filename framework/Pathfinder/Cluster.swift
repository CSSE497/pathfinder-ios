//
//  Cluster.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/**
A container in which transports are routed to transport commodities. Every registered Pathfinder application is created one default cluster. Additional sub-clusters can be created by the developer through the Pathfinder web interface.

This class should not be instantiated directly since it represents the state of the Pathfinder backend service. Instead, use the factory methods in the Pathfinder class. The typical use case of creating a Cluster object is to set a delegate for it which will receive all of the updates defined in `ClusterDelegate`.
*/
public class Cluster {

  // MARK: - Class Properties -

  /// The path to the default cluster for an application.
  public static let defaultPath = "/root"

  // MARK: - Instance Variables

  /// The path to the cluster within the application.
  public let id: String

  /// True if the connection to Pathfinder is active.
  public var connected: Bool

  /// All of the routes that are currently in progress for the cluster.
  public var routes: [Route]

  /// The transports that are currently online within the cluster.
  public var transports: [Transport]

  /// The commodities that are currently waiting on transit or are in transit within the cluster.
  public var commodities: [Commodity]

  /// The delegate that will receive notifications when any aspect of the cluster is updated.
  public var delegate: ClusterDelegate?

  // MARK: - Methods -

  /**
  Attempts to authenticate and retrieve a reference to the requested cluster. If the connection succeeds, the corresponding method on the delegate will be executed.
   
  If successful, the fields of the instance will be replaced by the Pathfinder-backed values, e.g. the list of transports. However, these will not be kept up to date unless you subscribe.
  */
  public func connect() {
    connect { _ in }
  }

  /**
  Requests that the Pathfinder server send push notifications to the cluster's delegate whenever any information changes in the cluster.
  
  Push notifications will be sent when:

  * New commodities or transports are created within the cluster.
  * Commodities request transportation within the cluster.
  * Commodities cancel their transportation request.
  * Vehicles in the cluster receive a new route.
  * Vehicles pick up or drop off commodities.
  */
  public func subscribe() {
    conn.subscribe(self)
  }

  /// Stops the Pathfinder service from sending update notifications.
  public func unsubscribe() {

  }

  /**
  Registers the current device as a transport with the Pathfinder service or uses the user's authentication to determine if an existing transport record exists and retrieves it. This will NOT set the transport to the online state. No routes will be generated for the transport until it is set to online. If the connection is authenticated and succeeds, the corresponding method on the delegate will be executed.

  - Parameter capacities:  The limiting constraints of the transport of the parameters of your application's routing calculations. The set of parameters needs to be defined and prioritized via the Pathfinder web interface in advance. All transports will be routed while keeping their sum occupant parameters to be less than or equal to their limiting constraints.
  */
  public func createTransport(status: Transport.Status, metadata: [String:AnyObject]) -> Transport {
    return Transport(cluster: self, metadata: metadata, status: status)
  }

  /**
  Constructs a reference to a previously created vehicle within the cluster. T
  */
  public func getTransport(id: Int) -> Transport {
    return Transport(cluster: self, id: id)
  }

  /**
   Requests transportation for a physical entity from one geographical location to another. This will immediately route a transport to pick up the commodity if one is available that can hold the commodities parameters within the transports capacity. If the connection is authenticated and succeeds, the corresponding method on the delegate of the returned commodity will be executed.

   - Parameter start:        The starting location of the commodity.
   - Parameter destination:  The destination location of the commodity.
   - Parameter parameters:   The quantities the parameters of your application's routing calculations. The set of parameters needs to be defined and prioritized via the Pathfinder web interface in advance.
   */
  public func createCommodity(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, metadata: [String:AnyObject]) -> Commodity {
    return Commodity(cluster: self, start: start, destination: destination, metadata: metadata)
  }

  public func getCommodity(id: Int) -> Commodity {
    return Commodity(cluster: self, id: id)
  }

  let conn: PathfinderConnection

  convenience init(conn: PathfinderConnection) {
    self.init(conn: conn, path: Cluster.defaultPath)
  }

  init(conn: PathfinderConnection, path: String) {
    self.id = path
    self.transports = [Transport]()
    self.commodities = [Commodity]()
    self.routes = [Route]()
    self.conn = conn
    self.connected = false
  }

  func connect(callback: (cluster: Cluster) -> Void) {
    if !connected {
      conn.getClusterById(id) { (resp: ClusterResponse) -> Void in
        self.connected = true
        self.transports = resp.transports
        self.commodities = resp.commodities
        self.delegate?.connected(self)
        callback(cluster: self)
      }
    }
  }
}