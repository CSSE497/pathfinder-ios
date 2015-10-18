//
//  CommodityDelegate.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

public protocol CommodityDelegate {

    func wasPickedUp()
    
    func wasDroppedOff()
    
    func wasCancelled()
    
    func wasRouted(r: Route)
}