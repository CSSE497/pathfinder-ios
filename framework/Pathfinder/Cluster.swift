//
//  Cluster.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

public class Cluster {
  var delegate: ClusterDelegate?
  
  let id: Int;
  let vehicles: [Vehicle]
  let commodities: [Commodity]
  
  public convenience init(id: Int) {
    self.init(id: id, vehicles: [Vehicle](), commodities: [Commodity]())
  }
  
  public init(id: Int, vehicles: [Vehicle], commodities: [Commodity]) {
    self.id = id
    self.vehicles = vehicles
    self.commodities = commodities
  }
}