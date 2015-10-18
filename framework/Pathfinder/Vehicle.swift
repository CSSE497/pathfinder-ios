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

*/
public class Vehicle {
  var route: Route?
  var delegate: VehicleDelegate?
  
  public init(capacities: [String:Int]) {
    
  }
  
  public func completeNextRouteAction() {
    
  }
  
  public func goOffline() {
    
  }
}
