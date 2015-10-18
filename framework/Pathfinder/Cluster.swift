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

*/
public class Cluster {
  var delegate: ClusterDelegate?

  let id: Int;
  let vehicles: [Vehicle]
  let commodities: [Commodity]

  convenience init(id: Int) {
    self.init(id: id, vehicles: [Vehicle](), commodities: [Commodity]())
  }

  init(id: Int, vehicles: [Vehicle], commodities: [Commodity]) {
    self.id = id
    self.vehicles = vehicles
    self.commodities = commodities
  }
}