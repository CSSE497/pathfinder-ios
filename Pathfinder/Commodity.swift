//
//  Commodity.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

public class Commodity {
    let id: Int
    let startLat: Double
    let startLng: Double
    let endLat: Double
    let endLng: Double
    
    public init(id: Int, startLat: Double, startLng: Double, endLat: Double, endLng: Double) {
        self.id = id
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
    }
    
    public func cancel() {
        
    }
}