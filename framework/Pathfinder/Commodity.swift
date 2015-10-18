//
//  Commodity.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/**
A commodity that has requested transportation via your application.

This class should never be instantiated directly because it represents the state of the data from the Pathfinder backend. Instead, request commodity transportation via the helper method in the Pathfinder class.

```
let clusterToRouteIn = self.cluster
let start = CLLocationCoordinate2D(latitude: startLat, longitude: startLng)
let end = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
let parameters = [String:Int]()
parameters["people"] = 2
parameters["sheep"] = 0
pathfinder.requestCommodityTransit(cluster: clusterToRouteIn, start: start, destination: end, parameters: parameters) { (c:Commodity) -> Void in
  c.delegate = self
  self.drawCommodityOnMap(c)
}
```

The primary purpose of creating a commodity is to set its delegate. The delegate will receive updates on the status of the commodity as defined in `CommodityDelegate`.
*/
public class Commodity {
  var delegate: CommodityDelegate?

  let id: Int
  let start: CLLocationCoordinate2D
  let destination: CLLocationCoordinate2D
  var route: Route?

  init(id: Int, start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
    self.id = id
    self.start = start
    self.destination = destination
  }

  /**
  Cancels the commodity request. The vehicle on route to pickup the commodity will be notified that the request was cancelled.
  
  - Parameter callback:  This function will be called once Pathfinder has verified that the commodity transit request was successfully cancelled.
  */
  public func cancel(callback: (success: Bool) -> Void) {

  }
}