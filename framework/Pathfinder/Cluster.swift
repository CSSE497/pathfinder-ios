//
//  Cluster.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

/**
A container in which vehicles are routed to transport commodities. Every registered Pathfinder application is created one default cluster. Additional sub-clusters can be created by the developer through the Pathfinder web interface.

This class should not be instantiated directly since it represents the state of the Pathfinder backend service. Instead, use the factory methods in the Pathfinder class. The typical use case of creating a Cluster object is to set a delegate for it which will receive all of the updates defined in `ClusterDelegate`.
*/
public class Cluster {
  var delegate: ClusterDelegate?

  let id: Int;
  let vehicles: [Vehicle]
  let commodities: [Commodity]
  let routes: [Route]

  init(id: Int, vehicles: [Vehicle], commodities: [Commodity]) {
    self.id = id
    self.vehicles = vehicles
    self.commodities = commodities
    self.routes = [Route]()
  }
}