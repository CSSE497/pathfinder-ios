//
//  Vehicle.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
A registered vehicle that can be routed to transport commodities.

This class should never be instantiated directly because it represents the state of the data from the Pathfinder backend. Instead, connect your device as a vehicle.

```
pathfinder.connectDeviceAsVehicle(cluster: myDefaultCluster, parameterCapacities: myCapacities) { (vehicle: Vehicle) -> Void in
self.vehicle = vehicle
}
```
*/
public class Vehicle {
  var route: Route?
  var delegate: VehicleDelegate?

  init(capacities: [String:Int]) {

  }

  /**
  Retrieve the next action that the driver of the vehicle will need to undertake. Currently, this is only pickups and dropoffs of commodities. If you want the entire queue of upcoming events, see the route field.

  - seealso: route
  */
  public func nextRouteAction() -> RouteAction? {
    return nil
  }

  ///Indicates that a vehicle has successfully completed one route action. It is the vehicles responsibility to indicate that they have picked up and dropped off their commodities. This method must be called, preferrably as the result of a UI interaction, when the driver acknowledges that they have picked up or dropped off a commodity on their route.
  public func completeNextRouteAction() {

  }

  /**
  Removes the vehicle from the set of active vehicles that can be routed. If the vehicle is on route to pick up commodities, all of those commodities will be rerouted with a new vehicle. If the vehicle is currently transporting passengers, it cannot go offline.

  - Returns: True if the vehicle is successfully turned offline.
  */
  public func goOffline() -> Bool {
    return false
  }
}
