//
//  Transport.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/**
A registered transport that can be routed to transport commodities.

This class should never be instantiated directly because it represents the state of the data from the Pathfinder backend. Instead, connect your device as a transport.

The standard use case involves creating a new vehicle within a known cluster. This can be accomplished as follows:

```swift
let pathfinder = Pathfinder(pathfinderAppId, userCreds)
let params = ["passenger": 3, "suitecase": 4]
let transport = pathfinder.cluster("/USA/West/Seattle").createTransport(params)
transport.delegate = self
transport.connect()
```
*/
public class Transport: NSObject {

  // MARK: - Enums -

  /// All transports exist in one of two states, online or offline. On creation, vehicles are placed into the offline state. Vehicles that are offline will not receive routes.
  public enum Status: String, CustomStringConvertible {
    case Offline = "Offline"
    case Online = "Online"

    public var description: String {
      switch self {
      case .Offline: return "Offline"
      case .Online: return "Online"
      }
    }
  }

  // MARK: - Instance Variables -

  /// The delegate that will receive notifications when any aspect of the cluster is updated.
  public var delegate: TransportDelegate?

  /// The route to which the transport is currently assigned, if there is one.
  public var route: Route?

  /// The limiting capacities of each parameter that cannot be surpassed at any point of a route.
  public var capacities: [String:Int]?

  /// The current state of the transports online/offline status.
  public var status: Status

  /// The unique id of the transport, as generated by Pathfinder.
  public var id: Int?

  // MARK: - Methods -

  /**
  Connects the local transport instance to the Pathfinder backend. Location updates will be send periodically to aid in routing calculations.

  The connection is not made until it is confirmed that the end-user has allowed the application to access his/her location. Pathfinder will not function if the user does not allow for the application to access his/her location.
  */
  public func connect() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.requestAlwaysAuthorization()
    locationManager?.startUpdatingLocation()
  }

  /**
  Subscribes to updates for the model. On each update to the transport in the Pathfinder service, a push notification will be sent and the corresponding method on the delegate will be called. Updates will be send on the following events:
   
  * The vehicle moved.
  * The vehicle was assigned a new route.
  * The vehicle picked up or dropped off a commodity.
  * The vehicle was removed or went offline.
  */
  public func subscribe() {
    self.cluster.conn.subscribe(self)
  }

  /// Stops the Pathfinder service from sending update notifications.
  public func unsubscribe() {

  }

  /**
  Retrieve the next action that the driver of the transport will need to undertake. Currently, this is only pickups and dropoffs of commodities. If you want the entire queue of upcoming events, see the route field.

  - seealso: route
  */
  public func nextRouteAction() -> RouteAction? {
    return route?.actions.first
  }

  /// Indicates that a transport has successfully completed one route action. It is the transports responsibility to indicate that they have picked up and dropped off their commodities. This method must be called, preferrably as the result of a UI interaction, when the driver acknowledges that they have picked up or dropped off a commodity on their route.
  public func completeNextRouteAction() {

  }

  /**
  Removes the transport from the set of active transports that can be routed. If the transport is on route to pick up commodities, all of those commodities will be rerouted with a new transport. If the transport is currently transporting passengers, it cannot go offline.
   
  When the vehicle is successfully taken offline, the corresponding method on its delegate will be called.
  */
  public func goOffline() {
    status = .Offline
    cluster.conn.update(self) { (TransportResponse) -> Void in

    }
  }

  var cluster: Cluster!
  var locationManager: CLLocationManager?
  var location: CLLocationCoordinate2D?

  init(cluster: Cluster, id: Int) {
    self.cluster = cluster
    self.id = id
    status = .Offline
  }

  init(id: Int, capacities: [String:Int], location: CLLocationCoordinate2D, status: Status) {
    self.id = id
    self.capacities = capacities
    self.location = location
    self.status = status
  }

  init(cluster: Cluster, capacities: [String:Int], status: Status) {
    self.cluster = cluster
    self.capacities = capacities
    self.status = status
  }

  init(clusterId: Int, id: Int, capacities: [String:Int], location: CLLocationCoordinate2D, status: Status) {
    self.id = id
    self.capacities = capacities
    self.location = location
    self.status = status
  }

  class func parse(message: NSDictionary) -> Transport? {
    if let id = message["id"] as? Int {
      if let capacity = message["capacity"] as? Int {
        if let latitude = message["latitude"] as? Double {
          if let longitude = message["longitude"] as? Double {
            if let statusStr = message["status"] as? String {
              let capacities = ["chimney": capacity]
              let status = Status(rawValue: statusStr)
              return Transport(id: id, capacities: capacities, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), status: status!)
            }
          }
        }
      }
    }
    return nil
  }
}

extension Transport: CLLocationManagerDelegate {

  /// :nodoc:
  public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("LocationManager authorization status changed: \(status)")
    if status == CLAuthorizationStatus.AuthorizedAlways {
      self.cluster.connect() { (cluster: Cluster) -> Void in
        self.cluster.conn.create(self) { (resp: TransportResponse) -> Void in
          self.id = resp.id
          self.delegate?.connected(self)
        }
      }
    }
  }

  /// :nodoc:
  public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Transport location updated to \(locations[0].coordinate)")
    location = locations[0].coordinate
    if id != nil {
      cluster.conn.update(self) { _ in }
    }
  }
}
